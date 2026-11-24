"""Selective, backed-up updates of mutable app preferences. Never run at build time."""
import argparse
import datetime
import json
import os
from pathlib import Path
import re
import shutil
import shlex
import stat
import subprocess
from maintenance import operation_lock, staging_file
import xml.etree.ElementTree as ET

REMOTE_SUNCALC = b"https://unpkg.com/suncalc@1.9.0/suncalc.js"


def patch_jsonc(text, updates):
    """Change top-level JSONC values without rewriting unrelated text/comments."""
    if not text.strip():
        return json.dumps(updates, ensure_ascii=False, indent=2) + "\n"
    masked = list(text)
    i = 0
    while i < len(text):
        if text[i] == '"':
            i += 1
            while i < len(text):
                if text[i] == "\\":
                    i += 2
                elif text[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
        elif text.startswith("//", i) or text.startswith("/*", i):
            if text.startswith("//", i):
                end = text.find("\n", i)
                if end < 0:
                    end = len(text)
            else:
                end = text.find("*/", i + 2)
                if end < 0:
                    raise ValueError("Unterminated JSONC comment")
                end += 2
            for j in range(i, end):
                if masked[j] not in "\r\n":
                    masked[j] = " "
            i = end
        else:
            i += 1
    comments_masked = "".join(masked)
    # A comma inside a string must not be mistaken for a trailing comma.
    i = 0
    in_string = False
    while i < len(masked):
        if masked[i] == '"':
            in_string = not in_string
        elif masked[i] == "\\" and in_string:
            i += 1
        elif masked[i] == "," and not in_string:
            j = i + 1
            while j < len(masked) and masked[j].isspace():
                j += 1
            if j < len(masked) and masked[j] in "}]":
                masked[i] = " "
        i += 1
    if masked and masked[0] == "\ufeff":
        masked[0] = " "
    clean = "".join(masked)
    data = json.loads(clean)
    if not isinstance(data, dict):
        raise ValueError("VS Code settings must be a JSONC object")
    decoder = json.JSONDecoder()
    i = clean.index("{") + 1
    edits = []
    found = set()
    last_end = i
    while True:
        while clean[i].isspace() or clean[i] == ",":
            i += 1
        if clean[i] == "}":
            closing = i
            break
        key, i = decoder.raw_decode(clean, i)
        while clean[i].isspace():
            i += 1
        if clean[i] != ":":
            raise ValueError("Invalid JSONC property")
        i += 1
        while clean[i].isspace():
            i += 1
        start = i
        value, i = decoder.raw_decode(clean, i)
        last_end = i
        if key in updates:
            found.add(key)
            if type(value) is not type(updates[key]) or value != updates[key]:
                edits.append((start, i, json.dumps(updates[key], ensure_ascii=False)))
    missing = {k: v for k, v in updates.items() if k not in found}
    if missing:
        separator = "," if data and "," not in comments_masked[last_end:closing] else ""
        addition = separator + "\n" + ",\n".join(
            "  " + json.dumps(k) + ": " + json.dumps(v, ensure_ascii=False) for k, v in missing.items()) + "\n"
        edits.append((closing, closing, addition))
    for start, end, value in reversed(sorted(edits)):
        text = text[:start] + value + text[end:]
    return text


def patch_ini(text, groups, flags=()):
    """Replace declared keys only; retain unknown lines, comments and sections."""
    lines = text.splitlines(keepends=True)
    for section, settings in groups.items():
        for key, value in settings.items():
            current = ""
            matches = []
            insertion = len(lines)
            found_section = section == ""
            for index, line in enumerate(lines):
                header = re.match(r"^\s*\[([^]]+)\]\s*(?:[#;].*)?$", line)
                if header:
                    if current == section:
                        insertion = index
                    current = header[1]
                    if current == section:
                        found_section = True
                        insertion = index + 1
                elif current == section:
                    insertion = index + 1
                    if re.match(r"^\s*" + re.escape(key) + r"\s*=", line):
                        matches.append(index)
            replacement = f"{key}={value}\n"
            if matches:
                lines[matches[0]] = replacement
                for index in reversed(matches[1:]):
                    del lines[index]
            else:
                if lines and not lines[-1].endswith("\n"):
                    lines[-1] += "\n"
                if not found_section:
                    lines.extend([f"\n[{section}]\n", replacement])
                else:
                    lines.insert(insertion, replacement)
    for flag in flags:
        if not any(line.strip() == flag for line in lines):
            lines.insert(0, flag + "\n")
    return "".join(lines)


def keymap_xml(text, name):
    parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True, insert_pis=True))
    root = ET.fromstring(text or "<application/>", parser=parser)
    component = next((c for c in root.findall("component") if c.get("name") == "KeymapManager"), None)
    if component is None:
        component = ET.SubElement(root, "component", name="KeymapManager")
    keymap = component.find("active_keymap")
    if keymap is None:
        keymap = ET.SubElement(component, "active_keymap")
    if keymap.get("name") == name:
        return text
    keymap.set("name", name)
    return ET.tostring(root, encoding="unicode") + "\n"


def build_plan(home, policy):
    writes = {}

    def read(relative):
        path = home / relative
        if Path(relative).is_absolute() or ".." in Path(relative).parts:
            raise ValueError(f"Unsafe policy path: {relative}")
        for component in [path, *path.parents]:
            if component == home:
                break
            if component.is_symlink():
                raise ValueError(f"Review existing symlink before activation: {path}")
        if path.exists() and not path.is_file():
            raise ValueError(f"Expected a regular file: {path}")
        return writes.get(relative, path.read_bytes() if path.exists() else b"")

    for op in policy["operations"]:
        relative = op["path"]
        old = read(relative).decode("utf-8")
        kind = op["kind"]
        if kind == "json":
            new = patch_jsonc(old, op["values"])
        elif kind == "text":
            new = op["value"]
        elif kind == "ini":
            new = patch_ini(old, op["values"], op.get("flags", ()))
        elif kind == "git-include":
            # Git's parser handles quoted subsection names and existing includes.
            result = subprocess.run(["git", "config", "--file", str(home / relative),
                                     "--get-all", "include.path"], capture_output=True, text=True)
            if result.returncode not in (0, 1, 128):
                raise ValueError(f"Cannot parse Git config: {relative}")
            if (home / relative).exists() and result.returncode == 128:
                raise ValueError(f"Cannot parse Git config: {relative}")
            new = old if op["include"] in result.stdout.splitlines() else (
                old.rstrip() + '\n[include]\n\tpath = ' + json.dumps(op["include"]) + '\n')
        else:
            raise ValueError(f"Unknown operation: {kind}")
        if new.encode() != read(relative):
            writes[relative] = new.encode()

    for directory, keymap in policy.get("jetbrains", {}).items():
        relative = f".config/JetBrains/{directory}/options/linux/keymap.xml"
        old = read(relative).decode()
        new = keymap_xml(old, keymap).encode()
        if new != old.encode():
            writes[relative] = new

    # Disable duplicate stale launchers without deleting their other metadata.
    for path in (home / ".config/autostart").glob("*.desktop"):
        # Plasma Manager and other applications can own autostart symlinks.
        # Never follow or modify them during opportunistic duplicate detection.
        # Explicitly managed paths still go through read() and remain protected.
        if path.is_symlink() or path.name in ("steam.desktop", "discord.desktop", "lunarclient.desktop"):
            continue
        relative = str(path.relative_to(home))
        text = read(relative).decode()
        command = re.search(r"^Exec=(.*)$", text, re.M)
        tokens = shlex.split(command[1]) if command else []
        if tokens and Path(tokens[0]).name == "env":
            tokens.pop(0)
            while tokens and ("=" in tokens[0] or tokens[0].startswith("-")):
                tokens.pop(0)
        executable = Path(tokens[0]).name.lower().lstrip(".") if tokens else ""
        if executable in {"steam", "discord", "discord-wrapped", "lunarclient"}:
            new = patch_ini(text, {"Desktop Entry": {
                "Hidden": "true", "X-GNOME-Autostart-enabled": "false"}}).encode()
            if new != text.encode():
                writes[relative] = new

    relative = ".zshrc"
    old = read(relative)
    new = re.sub(rb"(?m)^[ \t]*fastfetch[ \t]*(?:\r?\n|$)", b"", old)
    if new != old:
        writes[relative] = new

    assets = Path(policy["wallpaper"])
    for name in ["Background-Day.png", "Background-Night.png", "Sorey.png", "Mikleo.png", "index.html"]:
        relative = "bckg/" + name
        old = read(relative)
        if not (home / relative).exists():
            writes[relative] = (assets / name).read_bytes()
        if name == "index.html":
            source = writes.get(relative, old)
            new = source.replace(REMOTE_SUNCALC, b"suncalc.js")
            if new != old:
                writes[relative] = new
    return writes


def apply_plan(home, policy, writes, apply=True):
    root = home / ".local/state/nixconfig-home/backups"
    root.mkdir(parents=True, exist_ok=True, mode=0o700)
    backup = root / datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    backup.mkdir(mode=0o700)
    manifest = {}
    for relative in sorted(set(writes) | set(policy.get("backupPaths", []))):
        path = home / relative
        # Managed-file symlinks are copied as data for recovery, never followed
        # as destinations by the mutable updater.
        exists = path.exists() or path.is_symlink()
        manifest[relative] = {"exists": exists,
                              "mode": stat.S_IMODE(path.lstat().st_mode) if exists else None,
                              "link": os.readlink(path) if path.is_symlink() else None}
        if path.is_file():
            dest = backup / relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(path, dest)
            dest.chmod(0o600)
    (backup / "manifest.json").write_text(json.dumps(manifest, indent=2))
    if not apply:
        print(f"Pre-activation backup: {backup}; no preferences changed")
        return backup
    for relative, data in writes.items():
        path = home / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o600
        with staging_file(home, path.parent, ".nixconfig-") as (stream, tmp):
            stream.write(data)
            stream.flush()
            os.chmod(tmp, mode)
            os.replace(tmp, path)
    print(f"Preference backup: {backup}; changed {len(writes)} mutable files")


def restore_backup(home, backup, apply=False):
    """Explicit rollback of this backup's files only; preserve a safety copy."""
    manifest = json.loads((backup / "manifest.json").read_text())
    for relative, metadata in manifest.items():
        if Path(relative).is_absolute() or ".." in Path(relative).parts:
            raise ValueError("Unsafe path in backup manifest")
        path = home / relative
        for parent in path.parents:
            if parent == home:
                break
            if parent.is_symlink():
                raise ValueError(f"Review symlinked parent before restore: {path}")
        if path.exists() and not path.is_file():
            raise ValueError(f"Review non-file target before restore: {path}")
        if metadata["exists"] and metadata["link"] is None and not (backup / relative).is_file():
            raise ValueError(f"Backup data missing: {relative}")
    if not apply:
        print("Rollback preview; no files changed:")
        for relative, metadata in sorted(manifest.items()):
            print(("restore " if metadata["exists"] else "remove newly managed file ") + relative)
        return
    # This is deliberately separate from --apply, and never runs on activation.
    # Snapshot current values before the user's explicitly requested rollback.
    safety = apply_plan(home, {"backupPaths": list(manifest)}, {}, apply=False)
    for relative, metadata in manifest.items():
        path = home / relative
        if not metadata["exists"]:
            if path.is_file() or path.is_symlink():
                path.unlink()
            continue
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.is_symlink():
            path.unlink()
        if metadata["link"] is not None:
            if path.exists():
                path.unlink()
            path.symlink_to(metadata["link"])
        else:
            with staging_file(home, path.parent, ".nixconfig-restore-") as (stream, tmp):
                stream.write((backup / relative).read_bytes())
                stream.flush()
                os.chmod(tmp, metadata["mode"])
                os.replace(tmp, path)
    print(f"Restored {backup}; pre-rollback values saved in {safety}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--home", type=Path, required=True)
    parser.add_argument("--policy", type=Path, required=True)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--check", action="store_true")
    modes.add_argument("--apply", action="store_true")
    modes.add_argument("--backup", action="store_true")
    modes.add_argument("--restore", type=Path)
    parser.add_argument("--apply-restore", action="store_true")
    parser.add_argument("--lock-fd", type=int, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.apply_restore and args.restore is None:
        parser.error("--apply-restore requires --restore BACKUP")
    with operation_lock(args.home, inherited_fd=args.lock_fd):
        if args.restore is not None:
            restore_backup(args.home, args.restore, apply=args.apply_restore)
            return
        policy = json.loads(args.policy.read_text())
        writes = build_plan(args.home, policy)
        if args.apply:
            apply_plan(args.home, policy, writes)
        elif args.backup:
            apply_plan(args.home, policy, writes, apply=False)
        else:
            print("Home Manager link targets already present (review before activation):")
            for relative in policy.get("managedLinks", []):
                path = args.home / relative
                if path.exists() or path.is_symlink():
                    print(relative + (" [symlink]" if path.is_symlink() else " [file/directory]"))
            print("Planned mutable updates (no files changed):")
            for relative in sorted(writes):
                print(relative)


if __name__ == "__main__":
    main()

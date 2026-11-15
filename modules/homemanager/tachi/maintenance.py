"""Local, user-owned migration maintenance; never infer ownership from hm-* alone."""
import argparse
import atexit
from contextlib import contextmanager
import fcntl
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile
import uuid

STATE = Path('.local/state/nixconfig-home')
MARKER = '.nixconfig-validation.json'
PROVENANCE = {'tool': 'nixconfig-home-validation', 'version': 1}
_validation_locks = {}


def checked_path(home, path):
    """Reject redirected destinations; do not traverse symlinked parents."""
    home = Path(os.path.abspath(home))
    path = Path(os.path.abspath(path))
    if home.stat().st_uid != os.getuid():
        raise ValueError(f'HOME is not owned by the current user: {home}')
    relative = path.relative_to(home)
    current = home
    for part in relative.parts:
        current /= part
        if current.is_symlink():
            raise ValueError(f'Refusing symlinked maintenance path: {current}')
        if current.exists() and current.stat().st_uid != os.getuid():
            raise ValueError(f'Refusing another user\'s path: {current}')
    return path


def state_directory(home):
    path = checked_path(home, Path(home) / STATE)
    path.mkdir(parents=True, mode=0o700, exist_ok=True)
    if path.stat().st_mode & 0o022:
        raise ValueError(f'Maintenance directory is writable by others: {path}')
    return path


@contextmanager
def operation_lock(home, inherited_fd=None):
    """The same non-blocking lock covers clean, migration, backup and rollback."""
    root = state_directory(home)
    path = checked_path(home, root / 'operation.lock')
    fd = (os.dup(inherited_fd) if inherited_fd is not None else
          os.open(path, os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW, 0o600))
    try:
        info = os.fstat(fd)
        if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or info.st_uid != os.getuid():
            raise ValueError(f'Unsafe maintenance lock: {path}')
        if (info.st_dev, info.st_ino) != (path.stat().st_dev, path.stat().st_ino):
            raise ValueError('Inherited lock does not match the maintenance lock')
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise RuntimeError('Home Manager migration/rollback/validation or cleanup is active; retry after it finishes.') from None
        yield fd
    finally:
        os.close(fd)  # Never unlink the lock: that would permit two lock inodes.


def validation_directory(prefix):
    """Retain a marked test sandbox, holding the maintenance lock until exit."""
    home = Path.home()
    if home not in _validation_locks:
        lock = operation_lock(home)
        lock.__enter__()
        _validation_locks[home] = lock
        atexit.register(lock.__exit__, None, None, None)
    parent = checked_path(home, state_directory(home) / 'validation')
    parent.mkdir(mode=0o700, exist_ok=True)
    root = Path(tempfile.mkdtemp(prefix=prefix, dir=parent))
    (root / MARKER).write_text(json.dumps(PROVENANCE))
    return root


@contextmanager
def staging_file(home, parent, prefix):
    """Journal the exact inode, so interrupted writes can be cleaned safely."""
    registry = checked_path(home, state_directory(home) / 'staging')
    registry.mkdir(mode=0o700, exist_ok=True)
    fd, name = tempfile.mkstemp(dir=parent, prefix=prefix)
    path = Path(name)
    journal = registry / (uuid.uuid4().hex + '.json')
    try:
        info = os.fstat(fd)
        metadata = {'path': str(path.relative_to(home)), 'device': info.st_dev, 'inode': info.st_ino}
        journal.write_text(json.dumps(metadata))
        with os.fdopen(fd, 'wb') as stream:
            fd = None
            yield stream, path
    finally:
        if fd is not None:
            os.close(fd)
        # On a successful replace this name no longer exists. Never unlink a
        # replacement created by another process or an application.
        if path.exists() and 'info' in locals() and path.lstat().st_ino == info.st_ino and path.lstat().st_dev == info.st_dev:
            path.unlink()
        if journal.exists():
            journal.unlink()


def check_tree(path):
    """rmtree is symlink-safe; also refuse foreign ownership and mount points."""
    device = path.lstat().st_dev
    def failed(error):
        raise error
    for root, directories, files in os.walk(path, followlinks=False, onerror=failed):
        for node in [Path(root), *(Path(root) / name for name in directories + files)]:
            info = node.lstat()
            if info.st_uid != os.getuid() or info.st_dev != device or os.path.ismount(node):
                raise ValueError(f'Refusing foreign-owned/mounted cleanup entry: {node}')


def remove_tree(path):
    if path.is_symlink() or not path.is_dir():
        raise ValueError(f'Refusing non-directory cleanup target: {path}')
    check_tree(path)
    if not shutil.rmtree.avoids_symlink_attacks:
        raise RuntimeError('This Python lacks symlink-safe directory cleanup')
    shutil.rmtree(path)
    print(f'Removed {path}')


def legacy_validation(path):
    """Recognize old retained fixtures by their contents as well as their name."""
    if path.is_symlink() or not path.is_dir() or path.stat().st_uid != os.getuid():
        return False
    def text(name):
        f = path / name
        if (f.is_symlink() or not f.is_file() or f.stat().st_uid != os.getuid()
                or f.stat().st_size > 1024 * 1024):
            return ''
        return f.read_text()
    try:
        if path.name.startswith('hm-kwin-validation-'):
            return (text('window.qml') == 'import QtQuick\nimport QtQuick.Window\nWindow { visible: true; width: 600; height: 400; title: "Isolated snap validation" }\n'
                    and text('observe0.js') == 'const w = workspace.activeWindow; console.log("HM_TEST_GEOMETRY_0=" + JSON.stringify(w ? {x:w.frameGeometry.x,y:w.frameGeometry.y,width:w.frameGeometry.width,height:w.frameGeometry.height,output:w.output.name} : null));'
                    and 'kwin_wayland --virtual --no-lockscreen --no-kactivities --output-count 2' in text('run.sh'))
        if path.name.startswith('hm-plasma-validation-'):
            return (text('observe.js') == 'print(JSON.stringify({panels:panels().map(p=>({id:p.id,screen:p.screen,height:p.height,hiding:p.hiding,lengthMode:p.lengthMode,widgets:p.widgets().map(w=>w.type)})),desktops:desktops().map(d=>({id:d.id,screen:d.screen,widgets:d.widgets().map(w=>w.type)}))}));'
                    and 'kwin_wayland --virtual --no-lockscreen --no-kactivities' in text('run.sh')
                    and 'TACHI_WEATHER_UPDATED:' in text('weather.js'))
        if path.name.startswith(('hm-kconfig-Desktop-', 'hm-kconfig-Laptop-')):
            config = json.loads(text('input.json'))
            return (isinstance(config, dict) and len(config) >= 5
                    and all(Path(name).parent == path for name in config)
                    and 'UserCustom=keep-me' in text('kdeglobals')
                    and 'BatteryCriticalAction=1' in text('powerdevilrc'))
        if path.name.startswith('hm-js-test-'):
            script = text('test.js')
            return (script.startswith('\nfunction assert(ok, message) { if (!ok) throw new Error(message); }')
                    and "print('Snap cycling fixture: PASS');" in script
                    and "print('Tray weather fixture: PASS');" in script
                    and 'function configureTrayWeather(settings)' in script)
    except (OSError, ValueError, UnicodeError):
        return False
    return False


def active_legacy_directory(path, process_root=Path('/proc')):
    # Older runners lack the lock. Their command paths or private compositor's
    # ROOT identify the sandbox. Do not inspect unrelated desktop environments.
    needle = os.fsencode(path)
    for process in process_root.glob('[0-9]*'):
        try:
            if process.stat().st_uid != os.getuid() or int(process.name) == os.getpid():
                continue
            command = (process / 'cmdline').read_bytes()
            if needle + b'/' in command:
                return True
            tokens = command.split(b'\0')
            executable = Path(os.fsdecode(tokens[0])).name.lstrip('.')
            virtual_kwin = executable.startswith('kwin_wayland') and b'--virtual' in tokens
            shell = executable.startswith('plasmashell') and b'--no-respawn' in tokens
            if not (virtual_kwin or shell):
                continue
            if b'ROOT=' + needle + b'\0' in (process / 'environ').read_bytes():
                return True
        except (FileNotFoundError, ProcessLookupError):
            continue  # Process exited; no signal sent.
        except (OSError, ValueError):
            return True  # Cannot rule out a relevant writer: preserve it.
    return False


def cleanup(home, temporary_root=Path('/tmp')):
    """Caller holds operation_lock; tests inject a fresh temporary_root only."""
    root = state_directory(home)
    failures = []

    def attempt(path, action):
        try:
            action()
        except (OSError, ValueError, RuntimeError, KeyError, TypeError) as error:
            print(f'FAILED {path}: {error}', file=sys.stderr)
            failures.append(path)

    backups = checked_path(home, root / 'backups')
    if backups.exists():
        attempt(backups, lambda: remove_tree(backups))
    else:
        print(f'No migration backups: {backups}')

    validation = checked_path(home, root / 'validation')
    if validation.exists():
        for path in sorted(validation.iterdir()):
            marker = path / MARKER
            try:
                recognized = (not path.is_symlink() and path.is_dir() and not marker.is_symlink()
                              and json.loads(marker.read_text()) == PROVENANCE)
            except (OSError, ValueError):
                recognized = False
            if recognized:
                if active_legacy_directory(path):
                    print(f'FAILED active validation sandbox: {path}', file=sys.stderr)
                    failures.append(path)
                else:
                    attempt(path, lambda path=path: remove_tree(path))
            else:
                print(f'Preserved unrecognized validation entry: {path}')

    staging = checked_path(home, root / 'staging')
    if staging.exists():
        for journal in sorted(staging.iterdir()):
            def remove_staging(journal=journal):
                checked_path(home, journal)
                metadata = json.loads(journal.read_text())
                relative = Path(metadata['path'])
                if relative.is_absolute() or '..' in relative.parts or not relative.name.startswith('.nixconfig-'):
                    raise ValueError('Unsafe staging record')
                path = checked_path(home, Path(home) / relative)
                if path.exists():
                    info = path.lstat()
                    if not stat.S_ISREG(info.st_mode) or (info.st_dev, info.st_ino) != (metadata['device'], metadata['inode']):
                        raise ValueError(f'Staging inode changed; preserving {path}')
                    path.unlink()
                    print(f'Removed migration staging file {path}')
                journal.unlink()
                print(f'Removed staging record {journal}')
            attempt(journal, remove_staging)

    for path in sorted(temporary_root.iterdir()):
        if path.name.startswith(('hm-kwin-validation-', 'hm-plasma-validation-', 'hm-kconfig-Desktop-', 'hm-kconfig-Laptop-', 'hm-js-test-')):
            if legacy_validation(path):
                if active_legacy_directory(path):
                    print(f'FAILED active legacy test sandbox: {path}', file=sys.stderr)
                    failures.append(path)
                else:
                    attempt(path, lambda path=path: remove_tree(path))
            elif path.lstat().st_uid == os.getuid():
                print(f'Preserved unrecognized temporary entry: {path}')
    print(f'Home Manager cleanup finished; {len(failures)} failure(s).')
    return 1 if failures else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home', type=Path, required=True)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--system-clean', action='store_true', help='run existing nh clean all while holding the lock')
    mode.add_argument('--prepare-lock', action='store_true', help=argparse.SUPPRESS)
    args = parser.parse_args()
    try:
        with operation_lock(args.home):
            if args.prepare_lock:
                print(state_directory(args.home) / 'operation.lock')
                return 0
            if args.system_clean:
                result = subprocess.run(['nh', 'clean', 'all'])
                if result.returncode:
                    print('nh clean all failed; Home Manager cleanup skipped.', file=sys.stderr)
                    return result.returncode if result.returncode > 0 else 128 - result.returncode
                print('Nix cleanup completed: nh clean all', flush=True)
            return cleanup(args.home)
    except (OSError, ValueError, RuntimeError) as error:
        print(f'Cleanup failed: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())

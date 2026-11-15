# NixOS configuration refactoring roadmap

Repository: `Agrael11/nixconfig`

## Purpose and principles

This repository declares the desired software and behavior of two NixOS hosts, `Desktop` (physical tower) and `Laptop`. The goal is *content-based* declarative configuration: describe which software and settings are wanted, not freeze the versions forever. Do not add `flake.lock` to version control; its exclusion is intentional. The main nixpkgs input remains the stable release branch, with selectively newer packages/kernel where configured. Do not change this philosophy without discussion.

Refactor incrementally; preserve system behavior unless a change is expressly planned. Make small, reviewable local changes and test them *before* committing. Do not push untested changes. The Laptop has extremely limited free space (~30 MB at the time of planning), so avoid building on it or creating large store paths without verifying disk capacity.

## Ordered phases

### 1. Remove unnecessary global development packages

- Audit globally installed compilers, headers, SDKs, and development libraries, especially in `modules/24-cli-productivity.nix`.
- Remove unnecessary **global** development dependencies such as GCC and other compiler/toolchain libraries in preparation for per-project Nix dev shells.
- **Prefer replacing an SDK with its runtime-only equivalent when software still needs to execute programs built with that SDK.** For example, consider a suitable .NET runtime in place of the .NET SDK where appropriate. Verify that the replacement covers the installed applications; do not remove SDKs needed for global workflows without approval.
- **Retain graphical development applications** (VS Code, JetBrains IDEs, etc.). Do not remove general CLI tools or runtime libraries without determining their actual use.
- Inventory global environment variables such as `CPATH`, `LIBRARY_PATH`, `PKG_CONFIG_PATH`, and `CMAKE_PREFIX_PATH`; plan to scope these to dev shells as appropriate.
- Do not delete hardware or application compatibility packages merely because they resemble dev dependencies.

### 2. Configure direnv and IDE integration

- Configure `direnv` and `nix-direnv` declaratively, with the appropriate shell integration.
- Investigate declarative installation of compatible direnv / EnvFile-related JetBrains plugins; verify actual plugin support before changing settings.
- Validate activation of a simple project-local dev shell from terminal and VS Code / an applicable JetBrains IDE.
- Do not invent plugin identifiers or assume all IDE editions support identical plugins.

### 3. Deduplicate current declarations

- Remove repeated packages, e.g. `cowsay`, `fastfetch`, `git`, and repeated RetroDeck Flatpak declarations where appropriate.
- Consolidate duplicate settings between `config.nix` and `modules/30-services.nix` (PipeWire, SSH, OpenRGB, Flatpak, `nh`, Zsh, locale, timezone, etc.).
- Preserve the effective result and document any intentional redundancy.
- Some packages explicitly installed may already be part of the base system; don't delete them based on assumption alone.

### 4. Rename graphical modules to `gui`

- `desktop.nix` currently defines the shared graphical desktop environment. Rename or relocate it to `gui.nix` (or another GUI-focused module), reserving `desktop.nix` for the **physical Desktop PC host** in Phase 6.
- Rename graphical application modules such as `21-desktop-tools.nix`, `23-desktop-games.nix`, and `25-desktop-productivity.nix` to their `gui` equivalents.
- **Do not rename `config-desktop.nix` or `hardware-config-desktop.nix` as part of the GUI renaming.** These files belong specifically to the physical Desktop PC, not the shared graphical environment. They will be reorganized into the Desktop host configuration during Phase 6.
- Update all affected imports and relevant comments.
- Keep the flake host names `Desktop` and `Laptop` unchanged.
- Preserve all existing functionality. This phase is strictly a naming and relocation cleanup, not a configuration change.

### 5. Split modules by responsibility and interface

- Create parallel `modules/cli/` and `modules/gui/` hierarchies.
- Both may have categories such as browsers, text editors, file managers, games, productivity, and services; classify based on actual runtime/interface needs.
- Split CLI/headless services (e.g. SSH, Samba, Docker) from GUI/session-dependent services (e.g. Sunshine, TeamViewer). Services are not exclusively GUI or exclusively CLI.
- Separate graphic editors, video editors, web browsers, text editors, etc. into focused modules, rather than broadly lumping software into tools/productivity/gaming.
- Keep truly shared system configuration in `modules/common/` where useful and hardware-related overrides in clearly named locations.
- Reorganization should not change what each host installs until host-specific selection is introduced.
- Make sure the appropriate packages are in appropriate modules. If you aren't sure what package is, search it up. add cli based web browser.

### 6. Make each host the composition root

Proposed structure (illustrative, not rigid):

```text
flake.nix
hosts/
  desktop/
    default.nix                 # physical Desktop host composition
    hardware-generated.nix
    hardware-manual.nix
    cli-modules.nix             # explicit import selection
    gui-modules.nix             # explicit import selection
  laptop/
    default.nix                 # Laptop host composition
    hardware-generated.nix
    hardware-manual.nix
    cli-modules.nix
    gui-modules.nix
modules/
  common/
  cli/
  gui/
  hardware/                    # only if useful
  overrides/                   # only if useful
```

- The `Desktop` and `Laptop` entries in `flake.nix` should each import a **single host entry module**. Preserve host names and `nixosSystem` construction.
- Keep `specialArgs` in `flake.nix` for now: `extraExport`, `hres`, `vres`, `pkgs-unstable`, `inputs`. Potential future simplification can be discussed separately.
- The host entry point imports generated hardware settings, hand-written hardware settings, CLI selection, GUI selection, and relevant common/system settings.
- **Duplicating module import lists for each host is intentional and good.** Do not duplicate implementations unnecessarily. This lets Desktop and Laptop select different feature sets later.
- Keep `default.nix` focused on references to `hardware-modules.nix`, `common-modules.nix`, `cli-modules.nix`, and `gui-modules.nix`, plus host identity/installation-state declarations. Select individual modules in those lists; keep RetroArch and graphical application overlays in the GUI selection.
- Keep machine-specific system settings with the host, not mixed into shared graphical modules.
- Keep bootloader, EFI, Plymouth, kernel, and initrd policy in each host's `hardware-manual.nix`, not in a common boot module.
- Keep original generated hardware values intact when splitting manually authored configuration out.
- Treat `hardware-generated.nix` as the normal detected hardware and physical-filesystem baseline; keep detected drivers such as Laptop's `rtsx_pci_sdmmc`. Exclude captured Docker overlay mounts and `autofs` placeholders, retaining the actual declared network shares in manual settings.

### 7. Retest and retire obsolete workarounds carefully

- Remove Desktop `logind` inhibitor/power-key overrides, which were a workaround for a broken kernel 7.0 release and are no longer wanted.
- Retest whether the SC0710 module still needs unstable `stdenv`; keep its workaround until verified otherwise.
- Recheck MakeMKV and VS Code upstream build issues before removing overlays. MakeMKV workaround existed because nixpkgs packaging failed; VS Code workaround creates the missing `rg` path because its build tries to remove a binary Microsoft no longer ships.
- RetroArch `fbalpha2012 = null` workaround intentionally removes one broken core from `retroarch-full`; preserve unless an upstream fix is validated.
- Laptop's legacy NVIDIA 580 kernel patch is intentionally needed with kernel 7.2, which removed `strncpy`. The current broad source patch is fragile; preserve functionality unless a working upstream/pinned-patch replacement is tested.
- Audit host-specific kernel flags and initrd modules; don't casually remove hardware-specific flags.
- The user intentionally prefers the newest kernel even when this entails extra maintenance.

### 8. Remaining system hygiene

- Check each host's `system.stateVersion` against its *original installation state version*. This is not a release-version setting. Do not change without evidence and backup/compatibility review.
- Improve management of SMB credentials while keeping secrets out of the repository. Existing credential paths under `/etc/nixos/secrets/` require setup on a fresh install.
- Audit Samba share permissions and relevant filesystems. The user reports the guest share is effectively read-only, despite a `read only = no` Samba declaration; verify effective permissions, do not assume.
- Review exposed services while respecting the user's intentional remote-access needs (SSH, TeamViewer, Sunshine, Steam, ZeroTier, etc.). GUI remote-control consent prompts on Wayland may be examined separately.
- Migrate or package the user's `nixupdate` script eventually. Prefer `environment.localBinInPath = true` over a literal `~/.local/bin/` PATH session variable where appropriate.
- Retire the custom ISO mounting tool when no longer needed.
- Remove `nix-ld` only if dependent workflows still function.
- Keep the bootloader's intentionally hidden/zero-second menu on Laptop unless asked to change it.
- Do not enable system documentation or increase garbage-retention requirements merely for convention: disk space is a priority.
- The initially configured `initialPassword = "Nix"` for root and `tachi` is intentionally used for remote installation and should be changed immediately afterward. Verify actual deployed credentials are changed; do not expose new credentials or commit secrets.
- The user knowingly accepts convenience compromises such as indefinite sudo timestamp caching; do not silently alter the policy.

### 9. Configure Laptop → Desktop distributed builds, compatible with `update.sh`

- Make the physical `Desktop` an **optional Nix remote builder** for `Laptop`, never the reverse. The Laptop initiates its own ordinary update; eligible derivations are built on Desktop over SSH and outputs are returned to Laptop. Keep the existing `Desktop` and `Laptop` flake names.
- Put the client-side builder selection in Laptop host modules and the minimal SSH/build-service setup in Desktop host modules. Use `nix.distributedBuilds`, `nix.buildMachines`, and appropriate Nix daemon settings. Retain local building as a genuine fallback when Desktop is off, unreachable, busy, or in the middle of its own update. **Do not set Laptop's local `max-jobs` to zero.** Nix scheduling is not an all-or-nothing remote switch: some jobs may run locally even with Desktop online.
- Use a dedicated least-privilege build account and noninteractive SSH key with a verified host key. Never commit private keys, passwords, credentials, or machine-specific secrets. Confirm Nix store access and builder authorization before enabling network access. Avoid unnecessary firewall exposure and preserve the user's existing remote-access configuration.
- Prefer Desktop for expensive jobs without monopolizing it during gaming/streaming. Configure supported `x86_64-linux` features, capacity, parallelism, `speedFactor` / scheduling preferences, and (when justified) substitute handling based on observed behavior rather than guessing.
- **Preserve compatibility with the existing root `update.sh` / `nixupdate` workflow.** At the time of planning the script invokes `nh os "$action" --update -- --option max-jobs "$MAX_JOBS" --option cores "$CORES"` plus an optional `access-tokens` option. It defaults to `MAX_JOBS=2`, `CORES=4`, and reads overrides from the untracked `.lightswitch.conf` or CLI flags `-j/--jobs` and `-c/--cores`.
- Inspect how `nh` forwards these options into the actual Nix build; test whether `max-jobs` affects local concurrency and how `cores` affects build jobs. **Do not assume** the script's `-j` setting automatically specifies the remote builder's concurrency or prevents remote selection. If the CLI overrides conflict with the desired local/remote scheduling, revise `update.sh` deliberately, maintaining existing argument handling, defaults (unless an explicitly justified change is agreed), `setup`, `clean`, `all`, `boot`, `switch`, `reboot`/`--reboot`, `--shutdown`, `--sleep`, GitHub-token support, and failure/exit behavior.
- The ordinary `nixupdate` command must still work unchanged on both machines: on Laptop it should use Desktop when possible; on Desktop it must remain a **local** build, not accidentally route back to Laptop or itself. Check whether the script's `--update`/flake-lock handling and the deliberately untracked `flake.lock` affect repeatability or remote source availability. Do not introduce lock-file commits or require any new flag for normal operation.
- **Test actual offloading**, not just configuration evaluation: run a small forced build on Laptop and establish from build logs/remote processes that Desktop did the work; test the normal `nixupdate` path without unexpectedly activating a new system; test fallback while Desktop is offline, unavailable over SSH, or busy; test recovery from transient SSH failure and simultaneous updates. Protect Laptop storage from surprise large local rebuilds during testing.
- Full integration tests must also cover `nixupdate -j/--jobs`, `-c/--cores`, `boot`, `switch`, `--reboot`, and the script's cleanup modes, without triggering unintended reboot, activation, or cleanup during dry runs. Use isolated mocks/test harnesses for destructive actions until the user approves actual execution.
- **Remote building does not reduce the Laptop's final Nix store footprint.** Finished closures still need to be copied or downloaded to Laptop. Check available space before large builds; avoid deleting the current and last known-good generations to make a test pass. Keep the user's short-retention policy and intentionally untracked lock file.

### 10. Extract current user configurations — one draft Home Manager file per host

- Perform this **outside VS Code**, separately on the physical Desktop and Laptop, using local Codex/CLI tools where practical. This phase only captures data; it does **not** integrate or activate Home Manager.
- Inspect the current `tachi` user's actual settings: KDE Plasma/KWin/Konsole, shell, Git, editors/IDEs, application preferences, shortcuts, autostart entries, user systemd services, scripts, and gaming helpers. Try appropriate converters such as Plasma Manager's `rc2nix`, but inspect their output; there is no reliable universal Home Manager extractor.
- Produce **one self-contained draft Nix file per machine**: `future-homeless-desktop.nix` on Desktop and `future-homeless-laptop1.nix` on Laptop. These are snapshots for later comparison, not executable changes to the current configuration.
- Prefer native Home Manager / Plasma Manager settings when faithfully expressible; otherwise represent appropriate static user configuration files declaratively. Annotate assumptions, unsupported settings, application requirements, and settings that could be host-specific. Do not invent absent settings or assume a default is a deliberate preference.
- **Never capture or commit secrets** (SSH keys, credentials, cookies, tokens), browser profiles, VM disks, Steam game data or saves, caches, logs, histories, or other large/mutable state. Review/sanitize snapshots before sharing or committing. Do not overwrite existing dotfiles, modify live settings, add packages, or run `home-manager switch`/`nixos-rebuild`.
- Keep system-level responsibilities in NixOS; record possible migrations from system-wide to user-level configuration for later review without making them now.

### 11. Converge the two snapshots into common, Desktop, and Laptop drafts

- Perform the comparison and design decisions **outside VS Code**, in discussion using the two Phase 10 files as the source of truth. Do not silently resolve conflicts or assume whichever setting appears first is preferred.
- Produce exactly three **single-file draft** Home Manager configurations: `common.nix` for the `tachi` user on every host, `desktop.nix` for the physical Desktop only, and `laptop.nix` for the physical Laptop only. Their names here are illustrative draft locations; avoid confusion with the system's host modules.
- Put genuinely shared settings in common. Keep different device/display layouts, graphics, audio devices, machine-specific paths, shortcuts and other intentional exceptions in the relevant host file. If a preference differs, discuss whether it should be unified, overridden, or left unmanaged.
- Prefer common defaults plus narrow host overrides over duplicating an entire application's configuration. Check NixOS/Home Manager option merging semantics and avoid conflicting duplicate file ownership.
- Maintain the same no-secrets/no-state/no-activation safeguards as Phase 10. Compare the drafts with the original extractions and identify settings that could not be migrated faithfully.

### 12. Organize and integrate Home Manager by understandable categories

- Take the three reviewed Phase 11 drafts and split them into focused modules under `modules/homemanager/tachi/` (or a similarly clear layout): shell, Git, terminal, KDE/Plasma, development/editors, communication, media, gaming/Steam helpers, user services, scripts, and other suitable categories. Preserve an explicit **shared + per-host selection** model.
- Integrate Home Manager into the existing NixOS flake/host composition only at this phase. Use one consistent ownership model for each setting: move settings from NixOS modules when they genuinely belong to the user, without configuring the same option/file twice or accidentally removing system-wide functionality.
- Introduce Plasma Manager carefully; start with non-destructive settings and validate how it interacts with the current live Plasma profile and user configuration. Avoid any automatic overwrite of personal files without a review and backup.
- Steam game installation is **optional and later within this phase or a follow-up**, not a prerequisite. If pursued, declare a user-level AppID wishlist and an explicit install helper, potentially via SteamCMD after validating game compatibility, Steam authentication, and library location. **Never uninstall games** merely because an AppID was removed from the declarative list. Keep installed games, saves, and caches outside the Nix store; avoid automatic huge downloads during rebuilds.
- Decide how Home Manager activation interacts with the existing `nixupdate` / `update.sh` workflow. A NixOS-integrated Home Manager setup may be applied during `nh os` actions, while a standalone setup requires its own user-level activation. Preserve the familiar update command, distinguish system and user failures, and avoid unintended user-config replacements.
- Validate the common configuration plus each host-specific selection independently, compare actual options/files/packages to the pre-migration state, and test application behavior before enabling automatic activation. Do not consider a syntactically valid Nix expression sufficient proof of a safe migration.

## How to work on each phase

1. Inspect current sources and explain the proposed minimal diff.
2. Implement only the agreed phase or subtask locally.
3. Run evaluation or build checks suitable for the changed scope and report results. Build is not the same as activation.
4. Let the user explicitly decide if/when to activate the system, commit, or push.
5. Record any outstanding regressions or intentional exceptions here as the project evolves.

## Status

Phases 2–7 are implemented and validated locally. Phase 9 is accepted as complete after user-run offloading, unavailable-builder fallback, and recovery tests; remaining workload/concurrency checks are deferred to ordinary use. Phase 8 is not marked complete. The notes below record the checks and their limits; system activation remains a separate user decision. The intentionally untracked lock-file policy is unchanged. The ChatGPT web conversation and local VS Code Codex agent share this file as the planning reference.

Phase 12 is implemented for review, with non-activating evaluation/build and isolated migration/KDE tests. It is **not runtime-accepted**: first-activation conflict review/backups on both hosts, Laptop's live audit and physical application/power/display checks remain pending. See [the Home Manager implementation and activation guide](modules/homemanager/README.md). Native PowerDevil retains a fixed 60-second critical-battery warning; literal immediate suspend remains unimplemented.

Before Phase 12 activation, `update.sh` cleanup was extended to retain `nh clean all` and remove this user's local migration backups and positively identified validation/staging artifacts. A shared lock coordinates cleanup, activation, backups, rollback and retained validation tools. All backup categories are intentionally removed by `clean`/`all`; unrecognized temporary files are preserved. See the guide's unified-cleanup section for exact paths and limitations. The follow-up has non-activating host evaluations and isolated tests only; no real cleanup, rebuild, switch or existing-artifact deletion was performed.

### Phase 2 implementation and validation (2026-11-14)

- Enabled the NixOS `programs.direnv` module, Zsh integration, and nix-direnv in `modules/24-cli-productivity.nix`. Standard per-project `.envrc` approval remains required; no automatic trust was added.
- Declared VS Code extensions in `modules/25-desktop-productivity.nix`: `bbenoist.nix`, `mkhl.direnv`, `ms-vscode.cpptools`, `ms-vscode.cpp-devtools`, `ms-vscode.cpptools-extension-pack`, `ms-vscode.cpptools-themes`, `ms-vscode.cmake-tools`, `ms-vscode.makefile-tools`, `openai.chatgpt`, and `openai.codex-audio`. These cover the locally installed extension inventory plus direnv. The standard wrapper uses a Nix-managed extension directory; existing files under the user's extension directory are untouched. Add future extensions to this declaration and update/build through Nix.
- Added updating source-only inputs for `nix-community/nix-vscode-extensions` and `nix-community/nix-jetbrains-plugins`. VS Code Marketplace releases are filtered for the installed VS Code version and retain the catalog's Nix packaging fixes. JetBrains plugins are resolved separately for each IDE version. No plugin versions were hard-coded in this configuration, and the main package channels and intentionally untracked lock-file policy are unchanged. Catalog versions can differ from manually installed extensions; C/C++ DevTools currently resolves to 0.6.18 versus the locally installed 0.7.2.
- Added `io.github.salatmaster.direnv` ([direnv Everywhere](https://github.com/salatmaster/direnv-jetbrains-plugin)) to CLion, IntelliJ IDEA, RustRover, and Rider; added `avalonia-rider` to Rider, as requested. Verified Marketplace metadata, catalog compatibility with each installed IDE version, and plugin descriptors in the built packages. The older `systems.fehn.intellijdirenv` plugin is not used because its maintainer documents it as broken on recent IDEs. EnvFile was investigated but not installed: its documented run-configuration support varies, and this setup uses direnv directly.
- Passed Nix syntax checks, `git diff --check`, evaluation of both host toplevel derivations, and full builds of Desktop and Laptop on Desktop. No build ran on Laptop.
- Passed an isolated temporary flake/dev-shell test: unapproved `.envrc` rejected, project variable and executable loaded, nix-direnv cache reused, and the generated Zsh hook loaded/unloaded the environment on directory entry/exit. A real VS Code extension-host test on a virtual display loaded the same shell through `mkhl.direnv` and ran its executable. Temporary IDE settings and test fixtures were kept outside the repository.
- JetBrains interactive loading, C++ build/debug workflows, Avalonia preview/debug, Codex, and Codex Audio functionality have not been runtime-tested. Plugin installation and compatibility metadata do not establish these workflows work. Neither system has been activated by the agent.

After approved activation, start a fresh terminal and restart the IDEs. Each project should declare its own flake dev shell, use `use flake` in its `.envrc`, and explicitly approve that file with `direnv allow`. Open a trusted project in VS Code or JetBrains to load its environment. JetBrains may offer toolchains from the shell, but selecting the appropriate project SDK/toolchain remains a project setting.

### Phase 3 implementation and validation (2026-11-14)

- Removed the duplicate `git` entry from `modules/20-cli-tools.nix`, retaining Git in `modules/24-cli-productivity.nix` as requested. Kept one `cowsay` and one `fastfetch` selection in CLI tools. Removed the second global `coreutils` selection from `modules/26-isotools.nix`; CLI tools still installs it.
- Removed the repeated RetroDeck Flatpak entry from `modules/21-desktop-tools.nix`; the games module retains it. Bottles remains declared in GUI tools.
- Removed duplicated shared settings from `config.nix`, retaining their existing definitions in `modules/30-services.nix`: rtkit, PipeWire, OpenRGB, Flatpak, SSH, partition manager, nh and its cleanup settings, noisetorch, locale, console keymap, timezone/hardware clock, Zsh/Oh My Zsh, and disabled documentation. Kept the sudo command rule in `modules/10-users.nix` and removed its repeated rule from `config.nix`; sudo timeout and other unique configuration remain unchanged.
- Removed repeated SDDM enablement/theme selection from `modules/41-sddm-astronaut-theme.nix`. `desktop.nix` retains those settings; theme packaging and SDDM configuration files remain in the theme module.
- Intentional separate declarations remain: the ISO script's `runtimeInputs` specify its execution environment independently of global package selection; shell registration, user login-shell selection, and Zsh enablement serve separate purposes. Explicit host module import lists remain unchanged. Packages were not removed merely because they may already be provided by base-system modules.
- Captured evaluated before/after snapshots for both hosts. Unique system package and Flatpak sets, checked service/system settings (including SSH settings and firewall-opening behavior), sudo rule sets, and Zsh plugin sets are identical. Package-list entries decreased from 402 to 398 on Desktop and 408 to 404 on Laptop. Zsh's duplicated `git z git z` list is now `git z`; each host has one fewer duplicate sudo rule.
- Passed syntax checks, `git diff --check`, both host evaluations, and full builds of both hosts on Desktop. Compared the built system profiles: all 2,094 Desktop and 2,115 Laptop global command targets are identical before/after. Generated `sudoers` and `zshrc` changes were checked to contain only the expected duplicate removal. No activation or runtime service/hardware test was performed by the agent; no commit or push was made for Phase 3.

### Phase 4 implementation and validation (2026-11-14)

- Renamed the shared graphical/session module from `desktop.nix` to `gui.nix`, reserving the former name for future physical Desktop host organization. Renamed `modules/21-desktop-tools.nix`, `modules/23-desktop-games.nix`, and `modules/25-desktop-productivity.nix` to their `gui` equivalents.
- Updated imports in `flake.nix` and `config.nix` and relevant graphical-module/overlay comments. The physical-host files `config-desktop.nix`, `hardware-config-desktop.nix`, and `modules/32-samba-desktop.nix` retain their names. The flake host names remain `Desktop` and `Laptop`. NixOS option names, desktop-file conventions, and session `manage = "desktop"` values remain unchanged.
- Preserved file permissions. Registered the four new paths with Git's intent-to-add flag so Git-based flake evaluations include them; no file contents were staged and no commit or push was made for Phase 4.
- Passed syntax checks and `git diff --check`. Evaluated both host system derivations before and after the renames: Desktop and Laptop each produce exactly the same derivation path as before. Build checks for both hosts passed on Desktop by reusing the existing outputs; no recompilation was needed. No configuration behavior or package selection changed. No activation or runtime hardware test was performed.

### Phase 5 implementation and validation (2026-11-14)

- Replaced the mixed CLI/GUI tools and productivity modules with explicit `modules/cli/` and `modules/gui/` categories. CLI categories cover browsers, text editors, file managers, archives, storage/system tools, graphics diagnostics, network tools, media commands, productivity, Nix tools, ISO tools, and terminal entertainment. GUI categories cover browsers, text editors, development applications, file transfer/downloads, communication, media players, video editing/recording, disc tools, image editors, 3D tools, office, audio, storage/system tools, compatibility, remote access, virtualization management, games, and game sessions.
- Moved SSH, Samba, Docker/Compose, virtualization backends, and ZeroTier into `modules/cli/services/`. Moved Sunshine and TeamViewer into `modules/gui/services/`, with the FreeRDP graphical client in `modules/gui/remote-access.nix`. Retained the existing GameMode package in its CLI service/helper module without enabling additional services. Docker Compose and FFmpeg are now classified as CLI tools; Virt Manager is separate from the virtualization backends.
- Added `modules/common/` for users, shared locale/time/documentation settings, shell configuration, PipeWire/rtkit and speech-dispatcher, OpenRGB integration, runtimes/nix-ld libraries, Flatpak infrastructure, and the existing firewall declaration. Runtime libraries used by graphical and headless programs remain shared, including SDL, OpenAL, X11, Vulkan loader, Python, Mono, Java, and .NET. Git remains in CLI productivity with direnv/nix-direnv.
- Moved the application overlays and RetroArch workaround to `modules/overrides/`, and the SC0710 workaround to `modules/hardware/`. Nine moved implementations (users, ISO tools, CurseForge, Samba, firewall, SDDM theme, application overlays, RetroArch, and SC0710) were checked against the previous commit and remain byte-for-byte identical. The IDE/plugin implementation remains unchanged apart from relocating unrelated applications to their focused modules.
- Updated imports in `config.nix`, `gui.nix`, and `flake.nix`. These remain the current shared entry points; host composition, host-specific Samba shares, generated hardware files, boot settings, and other Phase 6 work were not reorganized. New module paths are registered with Git's intent-to-add flag for flake evaluation; file contents remain unstaged. No Phase 5 commit or push was made.
- Added the requested CLI browser in `modules/cli/browsers.nix`: w3m with `graphicsSupport = true` and `x11Support = true`. Nixpkgs bundles `w3mimgdisplay`, the equivalent of the separately named `w3m-img` package on other distributions. No separate package or invented package attribute was added.
- Passed syntax checks for all 62 Nix files and `git diff --check`. Captured both hosts before/after and verified package counts/multiplicities differ only by the addition of w3m (Desktop 398 → 399; Laptop 404 → 405). Flatpak selections and checked SSH, Samba, Sunshine, TeamViewer, Docker, virtualization, ZeroTier, and firewall settings are unchanged. All existing global command targets are unchanged; only `w3m`, `w3mman`, and `w3mimgdisplay` were added.
- Both full system builds passed on Desktop. Generated shell/PAM environment and display-manager configuration were checked to differ only in generated store references; existing session commands are preserved, with indentation normalized in the moved Steam launcher. No activation was performed. Hardware, remote-access sessions, and application workflows were not runtime-tested.
- w3m's version output confirms image support, local HTML rendering passed, and `w3mimgdisplay` decoded an 8×8 test image and reported its dimensions inside an isolated xterm on a virtual X display. This verifies the helper's image support; rendering within the user's preferred terminal/Wayland session remains untested. Test fixtures and logs are outside the repository.

### Phase 6 implementation and validation (2026-11-14)

- Each flake host now imports only `hosts/desktop/default.nix` or `hosts/laptop/default.nix`. Host names, inputs, `nixosSystem` construction, and all flake-level `specialArgs` remain unchanged.
- Each host has its own explicit `hardware-modules.nix`, `common-modules.nix`, `cli-modules.nix`, and `gui-modules.nix` selection lists. `default.nix` references only these lists and declares the host name/state version. Common lists select shared settings and Flatpak integration; hardware lists select generated/manual hardware and GRUB theme integration. GUI lists include RetroArch and graphical application overlays. Desktop selects SC0710 through its hardware list and its host-specific Samba shares through its CLI list, with the share implementation moved intact to `hosts/desktop/samba.nix`. Implementations remain shared, and each host's selections can be changed independently later.
- Replaced the old combined hardware files and supplied previews with each host's `hardware-generated.nix` and `hardware-manual.nix`. Generated files retain the detected pre-installation hardware/physical-filesystem baseline. Excluded Desktop's captured Docker overlay mount and Laptop's five scanned `autofs` placeholders. Preserved all six declared CIFS mounts, including `/media/main-shares/F`, with their existing paths, credential references, and automount options. Retained Desktop's six NTFS ownership/permission option lists as additional policy.
- Kept Laptop's detected `rtsx_pci_sdmmc` in its generated baseline, as requested; retained the existing supplemental USB/optical initrd modules in its manual settings. The card-reader module is the sole intended functional addition. All other captured kernel/initrd/boot settings are preserved.
- Bootloader/EFI/Plymouth/memtest settings, kernel choices and parameters, NVIDIA policy, and extra hardware settings are in each host's manual module. There is no common boot module. Preserved Laptop's zero-second menu and legacy NVIDIA patch, Desktop's current logind workaround, and the existing SC0710 workaround. Corrected relative boot-image asset paths for the new locations and verified image contents are identical.
- Moved shared Nix settings and sudo configuration into `modules/common/nix.nix` and `modules/common/sudo.nix`; moved the shared graphical-session implementation into `modules/gui/session.nix`. Host names and the existing `system.stateVersion = "26.05"` are explicitly declared per host without changing their values. Removed the superseded root aggregate/host files and preview files after distributing their declarations.
- Both hosts evaluate and build successfully on Desktop. Before/after comparisons preserve package counts/multiplicities, Flatpaks, every filesystem device/type/options tuple, swap settings, NVIDIA package paths and settings, captured firewall settings, host names, and state versions. Boot comparisons allow only Laptop's new card-reader module and source-path changes for identical image files. All 2,097 Desktop and 2,118 Laptop command targets are unchanged. Sudo directives are unchanged; only source-string indentation changed. Module relocation also changes package-list ordering for RetroArch and the GRUB theme, without changing their package paths or command targets.
- The final selection-list refinement also passed both evaluations/builds and setting comparisons. Generated D-Bus and terminfo contents are unchanged after normalizing generated paths; the remaining generated systemd differences are restart-trigger references. The system derivation hashes change with import ordering. All host/module files remain reachable through explicit imports, and each `default.nix` imports only its four selection files.
- Phase 6 Nix changes were committed as `6730124` after validation, with documentation committed separately. No Phase 6 activation, runtime hardware test, or push was performed. Successful evaluation/build does not establish runtime SD-reader or NVIDIA behavior. Test snapshots, original-file copies, and build logs are outside the repository.

### Phase 7 implementation and validation (2026-11-14)

- Removed Desktop's logind inhibitor/power-key override block, restoring normal inhibitor handling. The generated configuration now retains only the pre-existing NixOS `KillUserProcesses=false` setting; no Laptop logind behavior changed.
- Replaced the SC0710 wrapper with a direct upstream module import and deleted `modules/hardware/sc0710-fix.nix`. The upstream module uses `boot.kernelPackages.callPackage` for the driver; the wrapper's replacement of `pkgs.stdenv` did not affect its default driver/helper. Both evaluated derivations and installed outputs remain unchanged. This does not switch the driver's compiler away from the selected kernel package set.
- Removed the inactive MakeMKV overlay, which defined `makmkv` instead of the selected `makemkv` and contained invalid source declarations. The installed MakeMKV 1.18.4 already used the upstream package; its derivation and command target are unchanged.
- Removed the VS Code dummy-ripgrep pre-patch. The current 1.119.0 archive contains the expected `rg` path, the unmodified package builds, and both its CLI and packaged ripgrep execute successfully. The declarative extension selection remains unchanged.
- Removed RetroArch's `fbalpha2012 = null` overlay. The current upstream core is no longer marked broken, builds successfully, and the restored core in both built system packages loads and reports libretro API version 1. Game playback has not been tested.
- Removed Laptop's broad `strncpy` replacement patch and its added Python build dependency, retaining `legacy_580`. With NVIDIA 580.178.04 and kernel 7.3.4, patched and unpatched module sources are identical; the unpatched kernel-module build passes and all five compressed `.ko` files are byte-for-byte identical. NVIDIA user-space/Steam generated references consequently change, without changing their selected versions. Compatibility must be checked again when the driver or kernel updates.
- Retained the VLC Blu-ray overlay, host kernel parameters, initrd modules, boot policy, filesystem declarations, and all remote-access/firewall settings. Hardware-specific flag removal needs separate runtime evidence.
- Passed parsing of all 72 remaining Nix files, `git diff --check`, evaluation of both hosts, and full Desktop/Laptop system builds on Desktop. Before/after snapshots preserve mounts, swap, firewall, Flatpaks, host identity/state versions, and boot settings except the expected identical NVIDIA module output replacement and source-path changes for byte-identical splash images. Global command sets remain 2,097 on Desktop and 2,118 on Laptop; only VS Code/RetroArch targets and expected Laptop NVIDIA/Steam targets differ.
- No activation or runtime GPU, suspend/power-key, capture-card, or game test was performed. The user will test both physical hosts. Build/snapshot logs and smoke-test fixtures remain outside the repository. Nix changes and documentation are committed separately after validation; no push is authorized.

### Phase 9 preparation: local hostname lookup (2026-11-14)

- Added `modules/cli/services/mdns.nix` to both hosts' CLI selections, enabling Avahi's IPv4 NSS integration (`nssmdns4`). This lets ordinary applications such as `getent`, SSH, and Nix resolve `.local` hostnames on the same multicast-capable local network.
- Evaluation revealed that Avahi, hostname/user-service publishing, and UDP 5353 were already enabled indirectly on both hosts. Preserved these settings; no additional firewall exposure or SSH changes were necessary. The earlier direct-text inspection missed the inherited Avahi configuration.
- Both complete host derivations evaluate successfully. Before/after comparisons preserve Avahi settings except NSS integration, firewall rules, SSH settings, mounts, and kernel parameters. Targeted builds of both generated nsswitch configurations and the selected nss-mdns package passed. A full-system build dry run was inspected but not executed (221 derivations and approximately 1.3 GiB of downloads at the time, including prerequisites beyond this small change).
- The user authorized three separate commits (their Codex package addition, the mDNS Nix changes, and documentation) and a push. No activation was performed. After activation on both hosts, verify `getent ahosts Desktop.local` from Laptop; actual discovery and SSH connectivity remain untested. Remote-builder accounts, keys, scheduling, and update-script integration are still pending.

### Phase 9 implementation and accepted validation (2026-11-14)

- Added `hosts/desktop/remote-builder.nix` and `hosts/laptop/remote-builds.nix`, selected through each host's common-module list. Laptop uses `nix.distributedBuilds` with one `ssh-ng` builder at `Desktop.local`; Desktop has no remote builders. Laptop retains two local jobs/four cores by default, matching `nixupdate`, and allows Desktop to fetch its own substitutes. A relative remote speed factor is not a guarantee that every derivation runs remotely.
- Desktop uses NixOS's dedicated `nix-ssh` service account, forced to the Nix daemon protocol. Its account-specific policy permits only public-key authentication and disables forwarding and PTYs. The account is a trusted Nix user; its dedicated authorization file is `/var/lib/nix-remote-builder/authorized_keys`, provisioned at runtime, outside Git/store contents. Existing user login policy and firewall exposure are preserved. No private production key or live credential was generated or modified.
- Laptop's daemon identity is the runtime path `/var/lib/nix-remote-build/id_ed25519`. The public Desktop Ed25519 host key was read directly from the physical host and pinned declaratively. Builder-only SSH options require verified host keys/noninteractive authentication and bound connect/liveness timeouts. Keys and activation are left for the user's one-time setup.
- Verified from Nix 2.34.9's SSH store implementation that `ssh-ng` does not forward the client's cores option. Desktop now defaults to four cores per job (also affecting direct Desktop Nix builds); this matches the existing update-script default and avoids defaulting one remote build to all 28 threads. Explicit CLI overrides remain possible. One advertised remote slot is conservative for the observed 28-thread/32-GiB interactive host; these are scheduling/build hints, not hard quotas or automatic gaming/load detection.
- Kept `update.sh` unchanged. Added `hosts/tests/test-update.py`: eight passing test methods with multiple cases cover defaults, setup and symlink entry, config/CLI overrides, dummy-token forwarding, boot/switch and power precedence, cleanup/all, invalid arguments and failure exit behavior. All privileged/destructive commands are mocks in a temporary home; no actual activation, power action, cleanup, or real token was used.
- Actual small Desktop probe builds confirmed local `max-jobs`/`cores` behavior: two two-second probes took about 4.98 seconds with one job and 2.88 seconds with two jobs; each reported its requested `NIX_BUILD_CORES` (one/two respectively). A separate uncached probe attempted an unreachable loopback SSH builder and successfully fell back to one local job/core. These tests do not prove physical Laptop → Desktop offloading.
- Both complete host derivations evaluate. Before/after comparisons preserve firewalls, mounts, kernel/boot settings, and global SSH settings. Built SSH server Match rules were checked with a temporary test host key, confirming the Nix-only restrictions and unaffected `tachi` policy; Laptop's generated SSH client options were checked with `ssh -G`. Full system builds of Desktop and Laptop passed on Desktop, with build concurrency bounded to two jobs/four cores; no build ran on physical Laptop.
- Added `hosts/REMOTE-BUILDS.md` with runtime key provisioning, host-key verification, safe mock tests, and tiny online/local/unreachable/recovery/busy probes. The user performed setup and activation on the physical hosts. From Laptop, remote store access reported Nix 2.34.9 and `Trusted: 1`, and all eight mock update-script tests passed there.
- Physical Laptop → Desktop offloading passed: the supplied log explicitly shows a build on `ssh-ng://nix-ssh@Desktop.local`, `NIX_BUILD_CORES=4`, and the output copied back to Laptop. An unreachable loopback SSH builder then fell back successfully to a local Laptop build reporting `NIX_BUILD_CORES=1`. The user confirmed a fresh recovery probe returned to Desktop.
- The user accepted Phase 9 as complete without manufacturing another large build or repeating full updates. Actual Desktop-off/name-resolution timeouts, mid-build disconnects, busy-host behavior, simultaneous updates, and a full ordinary `nixupdate` using the builder remain unverified; observe these during normal use. Laptop free space was not independently measured by the agent. The mock workflow tests do not establish those live behaviors.
- No activation, commit, push, garbage collection, generation removal, or physical Laptop build was performed by the agent. `flake.lock` remains intentionally untracked. Input evaluation stays on the initiating host; remote store inputs do not require a shared Git checkout or lock-file commit.

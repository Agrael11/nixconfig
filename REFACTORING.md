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

### 9. Future: Laptop builds remotely on Desktop when available

- Make `Desktop` an optional Nix remote build machine for `Laptop` (not the reverse): Laptop requests builds; Desktop executes eligible build jobs over SSH; completed outputs become available to Laptop for installation.
- Use declarative NixOS settings, principally `nix.distributedBuilds`, `nix.buildMachines`, and, if appropriate, `nix.settings.builders-use-substitutes`. Keep builder-specific settings in host-appropriate modules.
- Prefer Desktop for build jobs when it is reachable, but **retain local build fallback** when Desktop is off, asleep, or unreachable. Do not set Laptop's local `max-jobs` to zero for normal operation. Verify actual scheduling and fallback rather than assuming the remote builder is always selected.
- Set up a dedicated, least-privilege remote-build identity and noninteractive SSH authentication suitable for the Nix daemon. Do not commit private keys; validate trusted-user requirements, SSH host verification, and access permissions before enabling.
- Tune concurrency, priority/speed factors, and supported system features for Desktop's available resources. Preserve both machines' `x86_64-linux` system targeting and avoid disrupting interactive use, gaming, or streaming on Desktop.
- Test successful offloading with Desktop online, graceful fallback with it offline, and recovery after transient network/SSH failures. Do not run an unexpected expensive local build when Laptop has critically low free disk space.
- **Remote builds reduce the Laptop's build CPU/RAM burden, not its ultimate installed disk use**: downloaded/copied outputs still occupy the Laptop's Nix store. Revisit free-space safeguards before rollout.
- This is a later phase; do not interrupt the current cleanup or alter live network/SSH settings to implement it yet.

### 10. Future: Home Manager

- Eventually integrate Home Manager at `modules/homemanager/tachi/` or a closely related layout.
- Move user-specific configurations (shell, Git, editors, app preferences, local scripts) progressively.
- Keep system-level and user-level ownership clear; avoid configuring the same setting twice.
- Home Manager is *not* a prerequisite for phases 1–9.

## How to work on each phase

1. Inspect current sources and explain the proposed minimal diff.
2. Implement only the agreed phase or subtask locally.
3. Run evaluation or build checks suitable for the changed scope and report results. Build is not the same as activation.
4. Let the user explicitly decide if/when to activate the system, commit, or push.
5. Record any outstanding regressions or intentional exceptions here as the project evolves.

## Status

Phases 2–6 are implemented and validated locally. The notes below record the checks and their limits; system activation remains a separate user decision. This plan includes the runtime-instead-of-SDK preference in phase 1 and a future optional Laptop → Desktop distributed-build phase. The ChatGPT web conversation and local VS Code Codex agent share this file as the planning reference.

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

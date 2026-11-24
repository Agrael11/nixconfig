# Phase 12: tachi Home Manager integration

Implementation is built and tested without activation. First activation still requires the user's approval, a local file audit and a pre-activation backup on **each** machine. Physical Laptop settings have not been inspected by this agent. Builds of both host configurations ran on Desktop.

## Structure and ownership

`hosts/{desktop,laptop}/home.nix` imports the shared NixOS integration in `modules/homemanager/default.nix` and selects `tachi/{desktop,laptop}.nix`. The latter import `common.nix`, which selects these shared implementations:

| Module | Responsibility |
| --- | --- |
| `plasma.nix`, `layout-data.json`, `tray-weather.js` | Panels, screen-specific monitors and the two weather configurations |
| `appearance.nix`, `wallpaper.nix`, `assets/` | Fusion/Vánok, Konsole menu, original HTML wallpaper and local SunCalc |
| `shortcuts.nix`, `snap-cycle.js` | Native shortcuts and repeated half-screen snapping across monitors |
| `power.nix` | Idle, AC, critical-battery and locking policies |
| `locale-xdg.nix` | Slovak locale and declared XDG paths without directory migration |
| `development.nix` | Git, selected VS Code preferences and JetBrains keymaps |
| `gaming.nix` | Selected MangoHud and RetroArch preferences |
| `applications.nix`, `autostart.nix` | Shared application preferences and startup policy |
| `migration.nix`, `merge.py`, `maintenance.py`, `preserve-unset.nix` | Selective mutable updates, audit/backups/rollback and preservation of unset Plasma options |

NixOS still owns application installation/extensions, services, privileged scripts, hardware, storage, boot, networking and system locale. Its development module adds the compatible Visual Studio keymap plugin to CLion, Rider and RustRover. Its Zsh hook runs fastfetch for tachi; only an exact standalone fastfetch invocation is removed from the existing `.zshrc`. Other shell customization remains mutable. A customized `fastfetch --...` invocation is retained and should be reviewed if duplicate output appears.

Home Manager uses the existing system package set. Its five user packages are the audit helper, original HTML wallpaper plugin, snap script, advanced-weather widget and session-variable helper. Git/IDEs/VS Code are not installed twice. Documentation stays disabled; font configuration remains system-owned. `home.stateVersion = "26.05"` is the first Home Manager compatibility baseline and does not change either host's NixOS state version. The untracked lock-file policy and existing input channels remain unchanged.

## Implemented preferences

- Git identity/safe directories and GitHub CLI credential helpers; no credentials captured. Brave HTTP/HTTPS/HTML defaults.
- Slovak language and regional formats, with no `LC_ALL`. XDG paths use Desktop, Stiahnuté, Šablóny, Verejné, Dokumenty, Hudba, Obrázky, Video and Projekty. Automatic directory creation/update is disabled. Existing English directories and all their files stay where they are; creating or moving data later is a separate user action.
- Fusion style, Vánok decoration, hidden Konsole menu, no idle screen locking, current-monitor Print capture and active-window Alt+Print capture.
- Super+Up maximizes, Super+Down minimizes, Super+Shift+Left/Right moves screens. Super+Left/Right uses an actual KWin script: half-screen, restore, opposite half of the next monitor, restore, then the other half. A single monitor alternates half/restore. Windows with fullscreen or movement/resize restrictions are skipped; manual geometry changes reset the saved cycle.
- A floating bottom panel per screen, height 54, fit-content and DodgeWindows. Widget order: launcher, Handlová advanced weather, screen-local tasks, pager, margin separator, tray, clock, show desktop. Tray weather separately retains Banská Bystrica/BBC UK Met Office preferences. Runtime IDs are discovered rather than replayed. Existing panels are replaced by the approved design. Only the managed monitor-widget types on the selected desktop are replaced; unrelated desktop widgets and other desktops are preserved.
- AC has no inactivity dim, screen-off or suspend. Battery and low-battery profiles suspend after 900 seconds idle. Critical-battery action is suspend; the existing critical and low thresholds are preserved.
- Steam with `-pipewire` and Discord start on both hosts; Lunar Client is hidden. Recognized duplicate launchers are disabled in place, retaining their metadata. Unknown/custom wrapper launchers are preserved for review, rather than guessed at.
- The approved VS Code settings merge into JSONC, preserving unknown keys/comments. JetBrains XML updates only the active keymap component. MangoHud, RetroArch, MC, VLC, qBittorrent and MIME preferences update only declared keys. Game data, saves, browser profiles, torrent state and unrelated preferences remain application-owned.
- The four original PNGs and original HTML/plugin are bundled unchanged. Existing artwork is never replaced. Missing wallpaper files can be seeded from those originals; the only edit to existing HTML is replacing the exact external SunCalc 1.9.0 URL with `suncalc.js`. SunCalc and its license are bundled; Bratislava remains `48.1486, 17.1077`.
- OBS has no managed preferences or migration paths. Desktop's existing OBS panel icon is retained as a launcher only. GRUB-switching and monitor-switching scripts are untouched.

## Host differences

| Preference | Desktop | Laptop |
| --- | --- | --- |
| Captured active screens | Two, current 2× scaling retained | One internal display; existing scaling retained |
| Desktop monitor widgets | Screen 1 | Screen 0 |
| GPU sensor sources | `gpu/gpu1`, NVIDIA | `gpu/gpu0` NVIDIA and `gpu/gpu1` Intel |
| MangoHud font / FPS cycle | 28 / `0+60+120` | 12 / `60+120+0` |
| Resume lock | Off | On |
| Power button | Ignore | Suspend |
| Lid including AC/external screen | No new lid override | Suspend, including docked |
| Panel opacity | Screen 0 translucent, others adaptive | Translucent |
| Other exceptions | Preserve captured per-screen launchers | Preserve captured ELAN touchpad enable/typing behavior |

Output modes, connector UUIDs, EDIDs and `kwinoutputconfig.json` are not managed. The existing display/scaling configuration stays in place. CPU sensors are selected dynamically; GPU indexes come from the approved snapshots and must be checked against the running hardware after login. Logind receives only the approved host power-key/lid fallback settings; normal inhibitor handling is retained.

## Limits and remaining host checks

**Literal immediate critical-battery suspend is not implemented.** PowerDevil 6.6.6 starts a fixed 60-second warning timer when the critical threshold is reached. The supported action is configured as suspend, with the existing threshold untouched. Its notification offers “Sleep Now”. Removing that grace would require a separate policy/implementation; the current code does not claim zero-delay behavior.

Panels and widget placement were exercised in private Plasma sessions. Physical monitor hotplug/reordering, visual appearance, GPU readings, weather-provider availability, real keypress conflicts, application startup and actual suspend/resume/locking still require host testing. Private sessions deliberately lack the real hardware/system bus, so their sensor/PipeWire warnings are not proof of a host fault. Panel scripts run once per changed script, not automatically on every hotplug; review layouts after changing screen topology.

All required original artwork is present. No further assets are currently missing. Laptop still needs its own live file audit and confirmation of the captured GPU indexes/touchpad identification. User-local copies of Plasma plugins can take precedence over Nix-packaged copies: Desktop's bundled HTML plugin matches the original; review any different local plugin on Laptop before deciding ownership. No local plugins are deleted automatically.

## File ownership and first-activation conflicts

Applications stay closed during migration: an app can otherwise overwrite merged preferences from its in-memory state. XML serialization can normalize formatting, and Plasma Manager can reformat KConfig; backups preserve the originals. Malformed JSONC/XML, unexpected mutable-file symlinks and non-file mutable targets abort the selective merger before it writes preferences.

Home Manager owns new support files and a small set of explicit symlinks, including `.config/git/config`, `.config/user-dirs.dirs`, `.config/user-dirs.conf`, the packaged local SunCalc/license and Plasma Manager startup support. Existing native targets are **not** force-overwritten. The audit lists them; Home Manager's link-collision check remains enabled. Mutable application configuration files are not replaced by read-only symlinks.

The read-only Desktop audit found one existing native target: **`.config/user-dirs.dirs`**. Review its contents and adopt the declared paths only after backing it up. Additional conflicts may exist on Laptop or appear if settings change before activation. If an existing `.config/git/config` is found, preserve/incorporate its extra settings before adopting the managed Git fragment; do not lose custom includes or credentials. The existing root `.gitconfig` stays mutable and includes the managed fragment last on initial migration.

Plasma Manager's upstream unset values normally mean deletion, even with `overrideConfig = false`. `preserve-unset.nix` filters these unset entries so unrelated preferences, including custom battery thresholds, are retained. Deliberate deletion needs a separately reviewed migration. The upstream panel pre-command that removes the whole applet file is disabled. The native panel screen assignment is supplemented with the supported containment `screen` setter, because the upstream config write alone left both panels on screen zero in a real test. libplasma also treats an exact `(0, 0)` widget geometry hint as absent, centering the widget and ignoring its requested size. A positive one-pixel hint lets its layout grid place the top-left monitor correctly; the actual saved coordinates/sizes are tested within one logical pixel.

The automatic activation backup is made after Home Manager's write boundary and before the mutable/KConfig updates. It is **not** a substitute for an explicit backup before first activation and before resolving native-file collisions. Both backups live privately under `~/.local/state/nixconfig-home/backups/` and may contain personal settings; keep them outside Git.

## Validation record (2026-11-15)

Resolved versions: Home Manager release-26.05 `6eb2d33d1d0c95a37ef6443c88e6c1686012ee8b`; Plasma Manager `a19a2a029fa180911bd89c554dca1616e10f4c1d`; Plasma/KWin/PowerDevil 6.6.6; Qt 6.11.2. These are the inspected versions, not newly pinned dependency requirements.

- Both complete NixOS configurations and both integrated Home Manager generations evaluated and built on Desktop, with two build jobs/four cores. No build ran on physical Laptop.
- All 100 repository/draft Nix files parsed successfully; `git diff --check` passed.
- Ten merger tests cover JSONC/comments/trailing commas/BOM, INI preservation including VLC commented headers, XML, symlink refusal, exact artwork preservation, recognized/unrelated autostarts, protected files, backups and explicit rollback. Tests use temporary homes only.
- JavaScript API fixtures cover single/two-screen snapping, both directions, manual movement and fullscreen restrictions, plus tray discovery with arbitrary IDs.
- Actual KWin in a private D-Bus session exercised registered left/right actions with a real Wayland test window across two virtual outputs. Half/restore/cross/restore/half geometry was verified.
- Actual Plasma sessions exercised the emitted Desktop and Laptop panel/widget scripts. Assertions check screen assignment, panel count/order/height/hiding/length, all eight desktop widget coordinates/sizes (within one logical pixel) and real tray-weather configuration writes. They do not establish physical sensor or suspend behavior.
- The resolved upstream Plasma Manager writer was run against temporary KConfig fixtures for both hosts. Power enum `1`, battery/low-battery 900-second timeouts, critical suspend, existing thresholds, AC screen-off disable, Konsole root key, locking, shortcuts and unrelated keys were checked.
- Compatible Visual Studio keymap plugin archives built; their actual XML keymap name is `Visual Studio`. Original wallpaper HTML/four PNGs were compared byte-for-byte with Desktop's originals; coordinates retained.
- Baseline comparisons preserve global package name/count selections, mounts, firewall exposure, checked remote services, kernel/boot values and NixOS state versions. Only CLion/Rider/RustRover wrapper paths change for the keymap plugin. The intended logind power/lid settings and tachi's Zsh hook are the system behavior additions.
- Desktop's audit ran read-only. Laptop's live conflict audit and both hosts' first activation/runtime acceptance remain pending. No activation, reboot, live preference writes, commit or push was performed.

Tests live in `tests/`. `manifest.nix` is an evaluation projection for enabled managed files, generation paths, KConfig and user packages. `test_kconfig.py` accepts that JSON and the resolved Plasma Manager `script/write_config.py`. `test_scripts.py` accepts a QuickJS executable. `test_kwin.py` accepts `--qml` and `--direction left|right`. `test_plasma.py` accepts manifest JSON, the selected host's `programs.plasma.startup.desktopScript` JSON and `--host Desktop|Laptop`. These compositor tests create temporary homes, private session buses and virtual outputs, block access to the system bus, and never call Home Manager activation. Retained KWin/Plasma/KConfig/JavaScript fixtures now use marked subdirectories of `~/.local/state/nixconfig-home/validation/`. Keep their logs outside Git.

Option/API verification used the resolved Home Manager and Plasma Manager source trees, plus the matching KDE sources: [PowerDevil core](https://invent.kde.org/plasma/powerdevil/-/blob/v6.6.6/daemon/powerdevilcore.cpp), [action enums](https://invent.kde.org/plasma/powerdevil/-/blob/v6.6.6/daemon/powerdevilenums.h), [Plasma containment scripting](https://invent.kde.org/plasma/plasma-workspace/-/blob/v6.6.6/shell/scripting/containment.h), [ConfigFile implementation](https://invent.kde.org/plasma/plasma-workspace/-/blob/v6.6.6/shell/scripting/scriptengine_v1.cpp), and [KWin window API](https://invent.kde.org/plasma/kwin/-/blob/v6.6.6/src/window.h), and [libplasma widget geometry handling](https://invent.kde.org/plasma/libplasma/-/blob/v6.6.6/src/plasmaquick/plasmoid/containmentitem.cpp).

## First activation: Desktop

This is a procedure for a later, explicitly approved activation; it has not been executed.

1. Save work, close all affected applications and log out of Plasma into a TTY as tachi. Record the current `/run/current-system` store path and retain its system generation. Protect it with an explicit GC root outside Git (for example, `nix-store --add-root /home/tachi/phase12-before-system --indirect --realise OLD_PATH` using that recorded path). Check free space in `/nix/store` and `/home/tachi`; keep the current and known-good generations. Do not use cleanup to make the migration fit.
2. Build the reviewed Desktop toplevel and `nixosConfigurations.Desktop.config.home-manager.users.tachi.home.activationPackage` from this checkout. Retain both output paths with explicit local out-links outside Git. Do not refresh inputs between audit and activation. The usual `nixupdate` defaults to updating and activation, so use explicit builds for this review.
3. Run the new Home Manager generation's `home-path/bin/tachi-home-audit --check` as tachi. This only lists conflicts/planned mutable updates. Inspect those files and any unknown Steam/Discord/Lunar wrapper launchers.
4. Run the same helper with `--backup`. Save the printed **pre-activation backup** path separately. This copies the managed-file whitelist and planned updates without changing preferences. Confirm it includes the original `user-dirs.dirs`, applet/KWin/shortcut/power files, application files and wallpaper HTML. A backup is not a migration of user data.
5. Resolve each reviewed native collision manually after the backup. For the observed `user-dirs.dirs` conflict, compare its current paths with the declaration, then move only that reviewed configuration file into the private backup area if adopting Home Manager ownership. Do not move/create/delete the actual Documents, Downloads or other data directories. Do not blanket-force all targets or automatically overwrite symlinks. Re-run the audit; existing writable app preferences are expected to remain for selective merging.
6. Only after explicit approval, activate the **exact built Desktop system**: set `/nix/var/nix/profiles/system` to its saved store path using `sudo nix-env --profile /nix/var/nix/profiles/system --set PATH`, then run that path's `bin/switch-to-configuration switch`. These are privileged activation commands, not checks. Home Manager runs as the NixOS `home-manager-tachi.service`; no separate flake/switch is needed.
7. Inspect `systemctl status home-manager-tachi.service` and its journal. A system activation can partly succeed while the Home Manager service fails; inspect both results. Log into a fresh Plasma session so the packaged plugin paths/session variables are available. Verify both screens/scales, widgets/sensors, arrows/Print, autostart, apps and power behavior before accepting the migration.

Later ordinary `nixupdate`/`nh os` activations include Home Manager automatically. The update script itself is unchanged. GUI preferences reapply only according to their module/startup policy; new input versions still need validation.

## First activation: Laptop

Use the same seven steps **locally on Laptop**, replacing Desktop with Laptop in build attributes and using only the built Laptop system. Check Laptop free space before any build or copying closures: remote building does not reduce the final store footprint. Retain the Laptop's own previous system path and its own pre-activation backup; never use Desktop's backup there.

The native collision list is unknown until `tachi-home-audit --check` runs there. Review local Plasma plugins, any different app config paths and JetBrains directories in particular. After fresh login verify the single-screen panel, both GPU sensor labels/readings, touchpad, 1080p widget layout, resume lock and lid/power button behavior on both AC and battery, including when an external screen is attached. Do not induce a critical-battery event just to test configuration; its runtime policy remains an explicit acceptance item.

## Rollback: either host

Use the paths recorded **on that same host**. A NixOS generation rollback alone does not restore mutable user preferences or panels.

1. Close affected apps and log out of Plasma into a TTY. Select the recorded previous system with `sudo nix-env --profile /nix/var/nix/profiles/system --set OLD_PATH`, then run `OLD_PATH/bin/switch-to-configuration switch`. This requires explicit activation approval just as the forward switch does. Keep the new generation/audit helper reachable until the file rollback is finished.
2. As tachi, run the new generation's `home-path/bin/tachi-home-audit --restore PRE_ACTIVATION_BACKUP` to preview the exact whitelist restoration/removal list. Use the saved explicit pre-activation backup, not whichever automatic backup happens to be newest. Review the preview, including native links, and confirm no desired later edits would be lost.
3. If approved, rerun with `--restore PRE_ACTIVATION_BACKUP --apply-restore`. It first snapshots the current values, restores backed-up contents/modes/links, and removes only newly managed files identified as absent in that manifest. It refuses unsafe paths or non-file destinations. Directories and other user files are not removed. OBS/protected scripts are outside the whitelist. Inspect reported failures rather than forcing them.
4. Log into a fresh session and verify restored behavior. Keep the old system closure, new audit helper and both backups until satisfied. The existing aggressive garbage-collection policy was not relaxed, so preserve reviewed store paths with explicit roots while needed; no automatic cleanup or generation deletion is part of this procedure.


## Unified cleanup before Phase 12 activation

`nixupdate clean` retains the existing `sudo -v` and `nh clean all` invocation, then cleans Home Manager leftovers as the calling user, on this host only. `all` performs that same cleanup before its existing update/options flow. No remote cleanup is run. The exit trap still clears cached sudo credentials.

The maintenance helper uses these exact locations:

- `~/.local/state/nixconfig-home/backups/`: **all** automatic, pre-activation, pre-rollback and incomplete migration backups, without an age filter. The entire directory is removed. This deliberately removes the file-rollback recovery copies; postpone `clean`/`all` until those copies are no longer needed. No additional confirmation prompt was added.
- `~/.local/state/nixconfig-home/validation/`: only generated sandbox directories with the exact tool provenance marker. Unrecognized entries are retained and reported. The retained validation tools now register here rather than scattering new directories in `/tmp`.
- `~/.local/state/nixconfig-home/staging/`: journals for interrupted mutable-file/rollback writes. Only the journal's exact temporary file under this user's home is removed, after checking its `.nixconfig-` name, device/inode and ownership. The actual destination configuration is never a cleanup target. Normal completion removes its own staging file/journal.
- `/tmp/hm-kwin-validation-*`, `/tmp/hm-plasma-validation-*`, `/tmp/hm-kconfig-Desktop-*`, `/tmp/hm-kconfig-Laptop-*` and `/tmp/hm-js-test-*`: older outputs are removed only when their generated fixture/script contents also identify them. A matching prefix alone is insufficient. Active sandbox processes are checked and their outputs retained with a failure report.

Loose `/tmp/hm-*` files, arbitrary temporary directories, the earlier ad hoc `hm-kwin-isolated-*` experiments and old **unjournaled** `.nixconfig-*` files are not automatically deleted. The tracked tools do not establish sufficient provenance for those names, and configuration contents or a filename prefix are not permission to remove arbitrary user files. An abrupt stop between creating a staging inode and recording its journal can also leave an unrecognized file; it is preserved. There is no broad `/tmp` glob deletion.

The persistent `~/.local/state/nixconfig-home/operation.lock` is outside the cleanup targets and is never unlinked. Cleanup holds it across both `nh` and user cleanup. Migration, audit, explicit backup, rollback and retained validation tools use the same nonblocking lock. NixOS-integrated Home Manager holds its descriptor from before the activation write boundary until the activation shell exits, including Plasma Manager's configuration writes. The merger inherits that descriptor. `all` releases the cleanup lock before starting the update, permitting the later activation to acquire it. A busy lock aborts with a retry message; it does not wait or terminate another process. Read-only preference audits now also create/use this coordination metadata, while leaving preferences unchanged.

Use the updated tools together: older already-built audit/activation programs cannot retroactively acquire this new lock. Do not mix an old migration helper with the new cleanup command. Phase 12 has not been activated here. Symlinked maintenance paths, another user's files and mounted backup subtrees are refused rather than followed. User cleanup uses no sudo. Missing directories are normal; removed paths, preserved unrecognized entries and failures are printed, and failures return a nonzero status. An `nh` failure preserves its status and skips user cleanup; a failed cleanup stops `all` before update/power actions.

Cleanup follow-up validation: 20 isolated maintenance tests, the 10 existing merger tests and the nine mock update-command tests pass. Tests cover missing directories, repeated execution, all backup categories, unrelated/live-file sentinels, provenance, symlinks/mounts, failed removal, inode checks, lock inheritance/exclusion and `nh` failure handling. Both host/Home Manager derivations evaluate; new coordination shell snippets and `update.sh` pass Bash syntax checks. This follow-up was not rebuilt or activated. No real cleanup command or pre-existing-file deletion was performed; only fresh test fixtures were removed by the test harnesses.

# Phase 10: INACTIVE Desktop user snapshot, captured 2026-11-14 as tachi on Desktop.
# Do not import this into the active flake yet. No Home Manager/Plasma Manager
# inputs, packages or activation were added. Phase 11 compares this with Laptop.
#
# DISCOVERED = read from local files (not inferred preference/default).
# INHERITED = supplied by NixOS or KDE defaults, recorded without a second owner.
# REVIEW/MANUAL = dependency, ambiguity, portability or incomplete migration.
# Snapshot presence does not establish that a default was deliberately chosen.
# This file contains all captured text inline: no reads from the live home or
# additional repository files are required to inspect the draft.
#
# EXTRACTION / VALIDATION
# Upstream rc2nix was not installed. Its Python script was downloaded into /tmp,
# inspected, then run on sanitized copies of eleven selected KDE config files.
# https://github.com/nix-community/plasma-manager/blob/trunk/script/rc2nix.py
# Script SHA256: 904296d8f9bcfe5baa30fbad8669201a4220760f7ddec3b0d0f56d733198fa0d
# Its shortcut output was independently compared with every source active binding.
# Its filtering omits colors, theme selection, panels and some host-specific data;
# audited source settings below supplement it. Raw KConfig strings use
# escapeValue=false to preserve existing escapes, including sensor regexes/JSON.
# API checked against upstream Plasma Manager modules/files.nix and shortcuts.nix.
# https://github.com/nix-community/plasma-manager
# Nix syntax/data checks only: no HM module evaluation, build or runtime migration.
#
# OWNERSHIP: KEEP IN NIXOS (Phases 11/12 may propose a deliberate transfer)
# modules/common/shell.nix: Zsh, Oh My Zsh agnoster, git/z plugins,
# PATH ~/.local/bin/ and XDG_CONFIG_HOME. /etc/zshrc also supplies aliases
# l='ls -alh', ll='ls -l', ls='ls --color=tty'; no custom user aliases found.
# modules/cli/productivity.nix: Git, direnv/nix-direnv and Zsh hook, Codex.
# modules/gui/development.nix: VS Code/extensions and JetBrains/direnv plugins.
# modules/gui/session.nix: Plasma 6, SDDM, portals, Slovak keyboard,
# NIXOS_OZONE_WL=1 and MANGOHUD=1. Host hardware/session variables stay there.
# Existing packages/Flatpaks, Steam/GameMode, audio, user/group/sudo, SSH servers,
# remote builder, Sunshine/TeamViewer, firewall, mounts and boot stay in NixOS.
# Enabled user units observed with systemctl --user list-unit-files come from
# system packages: Sunshine, WirePlumber, PipeWire sockets, speech-dispatcher,
# geoclue, obex, D-Bus, NixOS activation/sycoca and tmpfiles; no personal units
# were found under ~/.config/systemd/user. Do not recreate these in HM.
#
# ENVIRONMENT / ABSENCE FINDINGS
# Process environment: SHELL=/run/current-system/sw/bin/zsh, EDITOR=nano,
# LANG=en_US.UTF-8, LANGUAGE=sk, LC_TIME=sk_SK.UTF-8, LC_ALL=C.UTF-8.
# LC_ALL may be specific to this CLI process; do not declare it as a preference.
# VISUAL, ZDOTDIR, CPATH, LIBRARY_PATH, PKG_CONFIG_PATH and CMAKE_PREFIX_PATH unset
# in this process. No .zshenv/.zprofile/.zlogin/.profile/.bashrc/.bash_profile,
# .vimrc, nvim init, .nanorc, fish/starship/kitty/alacritty or user direnv config
# found at their conventional inspected paths. No private project envs inspected.
# No user ~/.ssh/config; no SSH keys/known_hosts/agents/authentication copied.
# No Konsole user profile in ~/.local/share/konsole; konsolerc only has version
# and empty UiSettings/ColorScheme. Terminal font/profile defaults are unproven.
# KDE kdedefaults inherits BreezeDark, breeze-dark icons, breeze_cursors and
# Breeze decoration library. Live kdeglobals overrides widgetStyle to Fusion
# and kwinrc records theme='Vánok'; preserve spelling, verify actual decoration.
#
# DISPLAY REVIEW (host-specific; do not replay stale kwinoutputconfig.json)
# kscreen-doctor -o: DP-2 3840x2160@143.99, scale 2, logical 0,0 1920x1080,
# priority 1; DP-3 3840x2160@160.00, scale 2, logical 1920,0 1920x1080,
# priority 2. Both enabled, rotation normal, VRR Never, HDR/WCG off, sRGB,
# brightness 100%; DP-2 prefers accuracy, DP-3 efficiency/performance.
# Saved DP-3 JSON disagrees (1920x1080@320); old DP-3/Unknown-1 records also exist.
# Retain no output JSON/EDID state; choose an explicit monitor policy in review.
# KWin tiling UUIDs below include stale displays: current DP-2 UUID is
# 6d8cfe82-3073-4199-bcce-8eaf91f891f7, DP-3 is
# 1d59241e-141f-48cf-ac48-6e3732691c83. All saved tile layouts are 25/50/25.
# Desktop/activity/containment IDs are local identities, not portable defaults.
#
# PANELS / WALLPAPERS REVIEW
# Panels 2 and 28: bottom (location=4), screens 0 and 1, floating, thickness 54,
# stored length mode=1 and visibility=2. Preserve numeric values pending UI/API
# comparison rather than guessing enum names. Opacity=2 / 0 respectively;
# panel 28 alignment=132. AppletOrder is preserved, including different launcher
# ordering on each screen. Both task managers show only their own screen.
# Desktop 20 has network/disk/memory/CPU/GPU graphs, CPU/GPU temperature and
# volume widgets. Sensor names and widget geometries are Desktop-specific.
# Raw low-level Plasma Manager config is used to preserve this topology;
# rc2nix does not extract it. Replay on a clean profile is NOT verified. Phase 12
# should translate to native panels/desktop widgets after identity/layout review;
# do not configure both high-level panel scripts and these raw groups together.
# Desktop icon positions, game shortcuts/screen mapping, popup/dialog sizes,
# migration flags, update stamps and wallpaper history/SlidePaths are omitted.
# Active wallpaper on both desktops is de.unkn0wn.htmlwallpaper using
# file:///home/tachi/bckg/index.html, InsecureHTTPS=true (discovered, not endorsed).
# Plugin exists in ~/.local/share/plasma/wallpapers; boidsaquarium11 also exists
# but is not selected. Neither plugin implementation is packaged by this draft.
# HTML below depends on manually retained Background-Night.png (4620818 bytes),
# Background-Day.png (3426714), Sorey.png (212157), Mikleo.png (202787).
# PNGs are not embedded. It loads SunCalc 1.9.0 from unpkg and uses coordinates
# 48.1486,17.1077 for sunrise/sunset. Review network dependency/assets separately.
# Inactive org.kde.image paths below may be unavailable on a fresh machine.
#
# APPLICATION / MANUAL MIGRATION LIMITS
# GitHub/gist helper commands delegate to gh auth git-credential. No auth material
# copied. Original helper: /nix/store/ak41fqdlgynk1awfrkdrrwvi5v5j90sk-gh-2.91.0/bin/gh.
# REVIEW: draft uses pkgs.gh instead of that obsolete store path; content-based
# package selection preserves helper intent, but recheck package/auth integration.
# No other global Git settings/includes were found in the inspected .gitconfig;
# ~/.config/git/config absent. Project-local Git settings were not inspected.
# Git identity below is discovered personal metadata; review before sharing.
# VS Code: seven explicit settings, no keybindings.json. Extensions stay in NixOS.
# Code chatLanguageModels.json and globalStorage/auth/session data not captured.
# JetBrains: CLion2026.2 present, VSCode keymap, Islands Dark scheme and Javadoc
# popup preference captured. Registry migration flags, caches, usage telemetry,
# credentials, project history, window states and default-only font XML omitted.
# No assumption is made about preferences in the other installed IDEs.
# Kate external tools are stock-looking installed templates; presence alone does
# not prove deliberate customization. Not copied; review custom tools if needed.
# OBS: safe user.ini preferences only; scenes/profiles/plugins/accounts/recordings
# are manual. global.ini duplicates older preferences and selects Untitled;
# no scenes, profile data or websocket authentication is copied.
# qBittorrent: queueing disabled and GUI logging disabled captured. Cookie state,
# torrent data, ports/network policy, histories/paths and UI geometry omitted.
# VLC: only uncommented setting found is qt-privacy-ask=0. Other sections contain
# commented defaults. Capture only that setting; interface recents/state excluded.
# RetroArch: selected safe driver/menu/video/savestate settings below only;
# remaining controls/core overrides/shaders/device setup need dedicated review.
# config_save_on_exit=true means a static HM symlink may conflict with GUI writes;
# same concern applies to OBS, htop, IDE/GTK integration and other mutable apps.
# NoiseTorch audio device name is Desktop-specific; no service enabled here.
# Autostart: Steam entry exact; Discord uses a recorded version-specific store
# path, Lunar uses an appimage-run CACHE path. Kept verbatim, fragile on reinstall
# or GC; replace deliberately after comparing intended executables/flags.
# Scripts are captured, not run. toggle.desktop uses Exec=~/toggle-screen.sh:
# tilde expansion may fail in desktop Exec; verify before choosing an absolute path.
# grubswitcher.sh calls /root/grubswitcher.sh, while the launcher and NixOS sudo
# rule use /root/grub-switcher.sh. Discovered mismatch, NOT repaired here. Launcher
# is recorded only; do not run power/boot helpers during validation.
# ~/.local/bin/nixupdate -> /etc/nixos/update.sh remains external/system workflow;
# do not duplicate or package the update script in this Phase 10 snapshot.
# ~/.nix-profile/bin has no entries; per-project dev shells/toolchains unchanged.
# Other root scripts/dev-environment/steamvr helpers and custom desktop launchers
# (Steam-generated games, Wine, Code, updater, VR) need separate workflow review.
#
# DELIBERATE EXCLUSIONS
# No passwords/tokens/SSH keys/GPG or wallet contents, gh auth config, SMB secrets,
# browser profiles, Discord account state, FileZilla sites, Sunshine/TeamViewer
# identity, OpenRGB binary profiles, application databases, VM/Wine data, Steam
# libraries/saves, histories, caches, logs or recent-file lists. Application
# directories were inventoried, not exhaustively read; GIMP/Blender/Kodi/OpenRGB/
# Minecraft/Lunar/CurseForge/Flatpak app preferences remain incomplete/manual.
# Nothing here proves absence of settings outside the explicitly inspected paths.
# Before Phase 12: choose HM stateVersion independently of system.stateVersion,
# supply/review HM and Plasma Manager modules, back up existing owned files,
# resolve mutable-file ownership and missing assets, then evaluate both hosts.
{ pkgs, ... }:
let
  # Values are already KConfig-escaped on disk; avoid a second escape pass.
  rawKConfig = builtins.mapAttrs (_group: builtins.mapAttrs (_key: value: {
    inherit value;
    escapeValue = false;
  }));
in
{
  home.username = "tachi";
  home.homeDirectory = "/home/tachi";
  # home.stateVersion deliberately undecided: there is no existing HM baseline.

  programs.git = {
    enable = true;
    package = null; # Git already comes from NixOS.
    settings = {
      user.name = "Tachi";
      user.email = "oliver.neuschl@gmail.com";
      safe.directory = "/etc/nixos";
      credential."https://github.com".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
      credential."https://gist.github.com".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
    };
  };

  programs.plasma = {
    enable = true; # Requires Plasma Manager module in a FUTURE integration.
    overrideConfig = false; # Never reset unrepresented live KDE settings.
    # DISCOVERED: 248 active/disabled bindings verified against kglobalshortcutsrc.
    shortcuts = {
      "ActivityManager" = {
        "switch-to-activity-e6547282-899b-4fc5-81a5-01a68f55408a" = [  ];
      };
      "KDE Keyboard Layout Switcher" = {
        "Switch to Next Keyboard Layout" = "Meta+Alt+K";
      };
      "kaccess" = {
        "Toggle Screen Reader On and Off" = "Meta+Alt+S";
      };
      "kmix" = {
        "decrease_microphone_volume" = "Microphone Volume Down";
        "decrease_volume" = "Volume Down";
        "decrease_volume_small" = "Shift+Volume Down";
        "increase_microphone_volume" = "Microphone Volume Up";
        "increase_volume" = "Volume Up";
        "increase_volume_small" = "Shift+Volume Up";
        "mic_mute" = [ "Microphone Mute" "Meta+Volume Mute" ];
        "mute" = "Volume Mute";
      };
      "ksmserver" = {
        "Halt Without Confirmation" = [  ];
        "Lock Session" = [ "Meta+L" "Screensaver" ];
        "Log Out" = "Ctrl+Alt+Del";
        "Log Out Without Confirmation" = [  ];
        "LogOut" = [  ];
        "Reboot" = [  ];
        "Reboot Without Confirmation" = [  ];
        "Shut Down" = [  ];
      };
      "kwin" = {
        "Activate Window Demanding Attention" = "Meta+Ctrl+A";
        "Cycle Overview" = [  ];
        "Cycle Overview Opposite" = [  ];
        "Decrease Opacity" = [  ];
        "Edit Tiles" = "Meta+T";
        "Expose" = "Ctrl+F9";
        "ExposeAll" = [ "Ctrl+F10" "Launch (C)" ];
        "ExposeClass" = "Ctrl+F7";
        "ExposeClassCurrentDesktop" = [  ];
        "Grid View" = "Meta+G";
        "Increase Opacity" = [  ];
        "Kill Window" = "Meta+Ctrl+Esc";
        "Move Tablet to Next LogicalOutput" = [  ];
        "Move Tablet to Next Output" = [  ];
        "MoveMouseToCenter" = "Meta+F6";
        "MoveMouseToFocus" = "Meta+F5";
        "MoveZoomDown" = [  ];
        "MoveZoomLeft" = [  ];
        "MoveZoomRight" = [  ];
        "MoveZoomUp" = [  ];
        "Overview" = "Meta+W";
        "Setup Window Shortcut" = [  ];
        "Show Desktop" = "Meta+D";
        "Suspend Compositing" = "Alt+Shift+F12";
        "Switch One Desktop Down" = "Meta+Ctrl+Down";
        "Switch One Desktop Up" = "Meta+Ctrl+Up";
        "Switch One Desktop to the Left" = "Meta+Ctrl+Left";
        "Switch One Desktop to the Right" = "Meta+Ctrl+Right";
        "Switch Window Down" = "Meta+Alt+Down";
        "Switch Window Left" = "Meta+Alt+Left";
        "Switch Window Right" = "Meta+Alt+Right";
        "Switch Window Up" = "Meta+Alt+Up";
        "Switch to Desktop 1" = "Ctrl+F1";
        "Switch to Desktop 10" = [  ];
        "Switch to Desktop 11" = [  ];
        "Switch to Desktop 12" = [  ];
        "Switch to Desktop 13" = [  ];
        "Switch to Desktop 14" = [  ];
        "Switch to Desktop 15" = [  ];
        "Switch to Desktop 16" = [  ];
        "Switch to Desktop 17" = [  ];
        "Switch to Desktop 18" = [  ];
        "Switch to Desktop 19" = [  ];
        "Switch to Desktop 2" = "Ctrl+F2";
        "Switch to Desktop 20" = [  ];
        "Switch to Desktop 21" = [  ];
        "Switch to Desktop 22" = [  ];
        "Switch to Desktop 23" = [  ];
        "Switch to Desktop 24" = [  ];
        "Switch to Desktop 25" = [  ];
        "Switch to Desktop 3" = "Ctrl+F3";
        "Switch to Desktop 4" = "Ctrl+F4";
        "Switch to Desktop 5" = [  ];
        "Switch to Desktop 6" = [  ];
        "Switch to Desktop 7" = [  ];
        "Switch to Desktop 8" = [  ];
        "Switch to Desktop 9" = [  ];
        "Switch to Next Desktop" = [  ];
        "Switch to Next Screen" = [  ];
        "Switch to Previous Desktop" = [  ];
        "Switch to Previous Screen" = [  ];
        "Switch to Screen 0" = [  ];
        "Switch to Screen 1" = [  ];
        "Switch to Screen 2" = [  ];
        "Switch to Screen 3" = [  ];
        "Switch to Screen 4" = [  ];
        "Switch to Screen 5" = [  ];
        "Switch to Screen 6" = [  ];
        "Switch to Screen 7" = [  ];
        "Switch to Screen Above" = [  ];
        "Switch to Screen Below" = [  ];
        "Switch to Screen to the Left" = [  ];
        "Switch to Screen to the Right" = [  ];
        "Toggle Night Color" = [  ];
        "Toggle Window Raise/Lower" = [  ];
        "Walk Through Windows" = "Alt+Tab";
        "Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
        "Walk Through Windows Alternative" = [  ];
        "Walk Through Windows Alternative (Reverse)" = [  ];
        "Walk Through Windows of Current Application" = "Alt+`";
        "Walk Through Windows of Current Application (Reverse)" = "Alt+~";
        "Walk Through Windows of Current Application Alternative" = [  ];
        "Walk Through Windows of Current Application Alternative (Reverse)" = [  ];
        "Window Above Other Windows" = [  ];
        "Window Below Other Windows" = [  ];
        "Window Close" = "Alt+F4";
        "Window Custom Quick Tile Bottom" = [  ];
        "Window Custom Quick Tile Left" = [  ];
        "Window Custom Quick Tile Right" = [  ];
        "Window Custom Quick Tile Top" = [  ];
        "Window Fullscreen" = [  ];
        "Window Grow Horizontal" = [  ];
        "Window Grow Vertical" = [  ];
        "Window Lower" = [  ];
        "Window Maximize" = "Meta+PgUp";
        "Window Maximize Horizontal" = [  ];
        "Window Maximize Vertical" = [  ];
        "Window Minimize" = "Meta+PgDown";
        "Window Move" = [  ];
        "Window Move Center" = [  ];
        "Window No Border" = [  ];
        "Window On All Desktops" = [  ];
        "Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
        "Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
        "Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
        "Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
        "Window One Screen Down" = [  ];
        "Window One Screen Up" = [  ];
        "Window One Screen to the Left" = [  ];
        "Window One Screen to the Right" = [  ];
        "Window Operations Menu" = "Alt+F3";
        "Window Pack Down" = [  ];
        "Window Pack Left" = [  ];
        "Window Pack Right" = [  ];
        "Window Pack Up" = [  ];
        "Window Quick Tile Bottom" = "Meta+Down";
        "Window Quick Tile Bottom Left" = [  ];
        "Window Quick Tile Bottom Right" = [  ];
        "Window Quick Tile Left" = "Meta+Left";
        "Window Quick Tile Right" = "Meta+Right";
        "Window Quick Tile Top" = [  ];
        "Window Quick Tile Top Left" = [  ];
        "Window Quick Tile Top Right" = [  ];
        "Window Raise" = [  ];
        "Window Resize" = [  ];
        "Window Shade" = [  ];
        "Window Shrink Horizontal" = [  ];
        "Window Shrink Vertical" = [  ];
        "Window to Desktop 1" = [  ];
        "Window to Desktop 10" = [  ];
        "Window to Desktop 11" = [  ];
        "Window to Desktop 12" = [  ];
        "Window to Desktop 13" = [  ];
        "Window to Desktop 14" = [  ];
        "Window to Desktop 15" = [  ];
        "Window to Desktop 16" = [  ];
        "Window to Desktop 17" = [  ];
        "Window to Desktop 18" = [  ];
        "Window to Desktop 19" = [  ];
        "Window to Desktop 2" = [  ];
        "Window to Desktop 20" = [  ];
        "Window to Desktop 21" = [  ];
        "Window to Desktop 22" = [  ];
        "Window to Desktop 23" = [  ];
        "Window to Desktop 24" = [  ];
        "Window to Desktop 25" = [  ];
        "Window to Desktop 3" = [  ];
        "Window to Desktop 4" = [  ];
        "Window to Desktop 5" = [  ];
        "Window to Desktop 6" = [  ];
        "Window to Desktop 7" = [  ];
        "Window to Desktop 8" = [  ];
        "Window to Desktop 9" = [  ];
        "Window to Next Desktop" = [  ];
        "Window to Next Screen" = "Meta+Shift+Right";
        "Window to Previous Desktop" = [  ];
        "Window to Previous Screen" = "Meta+Shift+Left";
        "Window to Screen 0" = [  ];
        "Window to Screen 1" = [  ];
        "Window to Screen 2" = [  ];
        "Window to Screen 3" = [  ];
        "Window to Screen 4" = [  ];
        "Window to Screen 5" = [  ];
        "Window to Screen 6" = [  ];
        "Window to Screen 7" = [  ];
        "disableInputCapture" = "Meta+Shift+Esc";
        "view_actual_size" = [  ];
        "view_zoom_in" = [ "Meta++" "Meta+=" ];
        "view_zoom_out" = "Meta+-";
      };
      "mediacontrol" = {
        "mediavolumedown" = [  ];
        "mediavolumeup" = [  ];
        "nextmedia" = "Media Next";
        "pausemedia" = "Media Pause";
        "playmedia" = [  ];
        "playpausemedia" = "Media Play";
        "previousmedia" = "Media Previous";
        "seekbackwardmedia" = "Media Rewind";
        "seekbackwardmedialong" = [  ];
        "seekforwardmedia" = "Media Fast Forward";
        "seekforwardmedialong" = [  ];
        "stopmedia" = "Media Stop";
      };
      "org_kde_powerdevil" = {
        "Decrease Keyboard Brightness" = "Keyboard Brightness Down";
        "Decrease Screen Brightness" = "Monitor Brightness Down";
        "Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
        "Hibernate" = "Hibernate";
        "Increase Keyboard Brightness" = "Keyboard Brightness Up";
        "Increase Screen Brightness" = "Monitor Brightness Up";
        "Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
        "PowerDown" = "Power Down";
        "PowerOff" = "Power Off";
        "Sleep" = "Sleep";
        "Toggle Keyboard Backlight" = "Keyboard Light On/Off";
        "Turn Off Screen" = [  ];
        "powerProfile" = [ "Battery" "Meta+B" ];
      };
      "plasmashell" = {
        "Slideshow Wallpaper Next Image" = [  ];
        "activate application launcher" = [ "Meta" "Alt+F1" ];
        "activate task manager entry 1" = "Meta+1";
        "activate task manager entry 10" = "Meta+0";
        "activate task manager entry 2" = "Meta+2";
        "activate task manager entry 3" = "Meta+3";
        "activate task manager entry 4" = "Meta+4";
        "activate task manager entry 5" = "Meta+5";
        "activate task manager entry 6" = "Meta+6";
        "activate task manager entry 7" = "Meta+7";
        "activate task manager entry 8" = "Meta+8";
        "activate task manager entry 9" = "Meta+9";
        "clipboard_action" = "Meta+Ctrl+X";
        "cycle-panels" = "Meta+Alt+P";
        "cycleNextAction" = [  ];
        "cyclePrevAction" = [  ];
        "edit_clipboard" = [  ];
        "manage activities" = "Meta+Q";
        "next activity" = "Meta+A";
        "previous activity" = "Meta+Shift+A";
        "repeat_action" = [  ];
        "show dashboard" = "Ctrl+F12";
        "show-barcode" = [  ];
        "show-on-mouse-pos" = "Meta+V";
        "stop current activity" = [  ];
        "switch to next activity" = [  ];
        "switch to previous activity" = [  ];
        "toggle do not disturb" = [  ];
      };
      "services/org.kde.spectacle.desktop" = {
        "ActiveWindowScreenShot" = "Alt+Print";
        "CurrentMonitorScreenShot" = "Print";
        "OpenWithoutScreenshot" = [  ];
        "RectangularRegionScreenShot" = "Meta+S";
        "WindowUnderCursorScreenShot" = [  ];
        "_launch" = "Meta+Shift+S";
      };
      "services/org.kde.touchpadshortcuts.desktop" = {
        "ToggleTouchpad" = "Touchpad Toggle";
      };
    };
    # DISCOVERED: explicit settings; no guessed Konsole profile/font or GTK theme.
    configFile = builtins.mapAttrs (_file: rawKConfig) {
      "kdeglobals" = {
        "ColorEffects:Disabled" = {
          "ChangeSelectionColor" = "";
          "Color" = "56,56,56";
          "ColorAmount" = "0";
          "ColorEffect" = "0";
          "ContrastAmount" = "0.65";
          "ContrastEffect" = "1";
          "Enable" = "";
          "IntensityAmount" = "0.1";
          "IntensityEffect" = "2";
        };
        "ColorEffects:Inactive" = {
          "ChangeSelectionColor" = "true";
          "Color" = "112,111,110";
          "ColorAmount" = "0.025";
          "ColorEffect" = "2";
          "ContrastAmount" = "0.1";
          "ContrastEffect" = "2";
          "Enable" = "false";
          "IntensityAmount" = "0";
          "IntensityEffect" = "0";
        };
        "Colors:Button" = {
          "BackgroundAlternate" = "28,100,14";
          "BackgroundNormal" = "41,44,48";
          "DecorationFocus" = "23,124,0";
          "DecorationHover" = "23,124,0";
          "ForegroundActive" = "23,124,0";
          "ForegroundInactive" = "161,169,177";
          "ForegroundLink" = "43,230,0";
          "ForegroundNegative" = "218,68,83";
          "ForegroundNeutral" = "246,116,0";
          "ForegroundNormal" = "252,252,252";
          "ForegroundPositive" = "39,174,96";
          "ForegroundVisited" = "155,89,182";
        };
        "Colors:Complementary" = {
          "BackgroundAlternate" = "30,87,116";
          "BackgroundNormal" = "32,35,38";
          "DecorationFocus" = "23,124,0";
          "DecorationHover" = "23,124,0";
          "ForegroundActive" = "23,124,0";
          "ForegroundInactive" = "161,169,177";
          "ForegroundLink" = "43,230,0";
          "ForegroundNegative" = "218,68,83";
          "ForegroundNeutral" = "246,116,0";
          "ForegroundNormal" = "252,252,252";
          "ForegroundPositive" = "39,174,96";
          "ForegroundVisited" = "155,89,182";
        };
        "Colors:Header" = {
          "BackgroundAlternate" = "32,35,38";
          "BackgroundNormal" = "41,44,48";
          "DecorationFocus" = "23,124,0";
          "DecorationHover" = "23,124,0";
          "ForegroundActive" = "23,124,0";
          "ForegroundInactive" = "161,169,177";
          "ForegroundLink" = "43,230,0";
          "ForegroundNegative" = "218,68,83";
          "ForegroundNeutral" = "246,116,0";
          "ForegroundNormal" = "252,252,252";
          "ForegroundPositive" = "39,174,96";
          "ForegroundVisited" = "155,89,182";
        };
        "Colors:Header/Inactive" = {
          "BackgroundAlternate" = "41,44,48";
          "BackgroundNormal" = "32,35,38";
          "DecorationFocus" = "61,174,233";
          "DecorationHover" = "61,174,233";
          "ForegroundActive" = "61,174,233";
          "ForegroundInactive" = "161,169,177";
          "ForegroundLink" = "29,153,243";
          "ForegroundNegative" = "218,68,83";
          "ForegroundNeutral" = "246,116,0";
          "ForegroundNormal" = "252,252,252";
          "ForegroundPositive" = "39,174,96";
          "ForegroundVisited" = "155,89,182";
        };
        "Colors:Selection" = {
          "BackgroundAlternate" = "22,93,7";
          "BackgroundNormal" = "22,93,7";
          "DecorationFocus" = "23,124,0";
          "DecorationHover" = "23,124,0";
          "ForegroundActive" = "23,124,0";
          "ForegroundInactive" = "255,255,255";
          "ForegroundLink" = "17,90,0";
          "ForegroundNegative" = "176,55,69";
          "ForegroundNeutral" = "198,92,0";
          "ForegroundNormal" = "255,255,255";
          "ForegroundPositive" = "23,104,57";
          "ForegroundVisited" = "155,89,182";
        };
        "Colors:Tooltip" = {
          "BackgroundAlternate" = "32,35,38";
          "BackgroundNormal" = "41,44,48";
          "DecorationFocus" = "23,124,0";
          "DecorationHover" = "23,124,0";
          "ForegroundActive" = "23,124,0";
          "ForegroundInactive" = "161,169,177";
          "ForegroundLink" = "43,230,0";
          "ForegroundNegative" = "218,68,83";
          "ForegroundNeutral" = "246,116,0";
          "ForegroundNormal" = "252,252,252";
          "ForegroundPositive" = "39,174,96";
          "ForegroundVisited" = "155,89,182";
        };
        "Colors:View" = {
          "BackgroundAlternate" = "29,31,34";
          "BackgroundNormal" = "20,22,24";
          "DecorationFocus" = "23,124,0";
          "DecorationHover" = "23,124,0";
          "ForegroundActive" = "23,124,0";
          "ForegroundInactive" = "161,169,177";
          "ForegroundLink" = "43,230,0";
          "ForegroundNegative" = "218,68,83";
          "ForegroundNeutral" = "246,116,0";
          "ForegroundNormal" = "252,252,252";
          "ForegroundPositive" = "39,174,96";
          "ForegroundVisited" = "155,89,182";
        };
        "Colors:Window" = {
          "BackgroundAlternate" = "41,44,48";
          "BackgroundNormal" = "32,35,38";
          "DecorationFocus" = "23,124,0";
          "DecorationHover" = "23,124,0";
          "ForegroundActive" = "23,124,0";
          "ForegroundInactive" = "161,169,177";
          "ForegroundLink" = "43,230,0";
          "ForegroundNegative" = "218,68,83";
          "ForegroundNeutral" = "246,116,0";
          "ForegroundNormal" = "252,252,252";
          "ForegroundPositive" = "39,174,96";
          "ForegroundVisited" = "155,89,182";
        };
        "General" = {
          "AccentColor" = "23,124,0";
          "LastUsedCustomAccentColor" = "23,124,0";
        };
        "KDE" = {
          "LookAndFeelPackage" = "org.kde.breezedark.desktop";
          "contrast" = "4";
          "frameContrast" = "0.2";
          "widgetStyle" = "Fusion";
        };
        "KScreen" = {
          "ScaleFactor" = "2";
          "ScreenScaleFactors" = "HDMI-0=2;DP-0=2;DP-1=2;DP-2=2;DP-3=2;DP-4=2;DP-5=2;";
        };
        "WM" = {
          "activeBackground" = "39,44,49";
          "activeBlend" = "252,252,252";
          "activeForeground" = "252,252,252";
          "inactiveBackground" = "32,36,40";
          "inactiveBlend" = "161,169,177";
          "inactiveForeground" = "161,169,177";
        };
      };
      "kwinrc" = {
        "Desktops" = {
          "Id_1" = "91e00ea8-57da-4e97-b0dc-567ac12d2284";
          "Number" = "1";
          "Rows" = "1";
        };
        "Effect-overview" = {
          "BorderActivate" = "9";
        };
        "Tiling/0527699f-c721-5dcd-a3db-312e7fa96496" = {
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/802b29b2-f965-58d6-941d-9c424653882e" = {
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/916bea45-2479-5537-b6a8-cb27facd197e" = {
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/91e00ea8-57da-4e97-b0dc-567ac12d2284/1d59241e-141f-48cf-ac48-6e3732691c83" = {
          "padding" = "4";
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/91e00ea8-57da-4e97-b0dc-567ac12d2284/6d8cfe82-3073-4199-bcce-8eaf91f891f7" = {
          "padding" = "4";
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/91e00ea8-57da-4e97-b0dc-567ac12d2284/af467572-34c4-4383-939a-e8f1e507b233" = {
          "padding" = "4";
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/91e00ea8-57da-4e97-b0dc-567ac12d2284/fe4009e8-dffb-4368-bfe2-23b1e852a186" = {
          "padding" = "4";
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/b8f4b307-5189-5e92-9301-b6d9e15b2b17" = {
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/d02c035d-eef0-5c68-aa2f-2e83d0ba08b1" = {
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/defdad5d-1af1-541e-96bb-6d71dabdbabc" = {
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/f6192747-8b3c-5a98-9d61-b45171335036" = {
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Tiling/fe932f7c-8164-53d3-a4d9-d6915c3af8d2" = {
          "tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        };
        "Windows_HDR" = {
          "MaxFrameAverage" = "0";
          "MaxLuminance" = "360";
          "Reference" = "320";
        };
        "Xwayland" = {
          "Scale" = "2";
        };
        "org.kde.kdecoration2" = {
          "theme" = "Vánok";
        };
      };
      "kcminputrc" = {
        "Mouse" = {
          "X11LibInputXAccelProfileFlat" = "true";
        };
      };
      "konsolerc" = {
        "General" = {
          "ConfigVersion" = "1";
        };
        "UiSettings" = {
          "ColorScheme" = "";
        };
      };
      "kscreenlockerrc" = {
        "Daemon" = {
          "Autolock" = "false";
          "Timeout" = "0";
        };
      };
      "plasma-localerc" = {
        "Formats" = {
          "LANG" = "en_US.UTF-8";
          "LC_ADDRESS" = "sk_SK.UTF-8";
          "LC_MEASUREMENT" = "sk_SK.UTF-8";
          "LC_MONETARY" = "sk_SK.UTF-8";
          "LC_NAME" = "sk_SK.UTF-8";
          "LC_NUMERIC" = "sk_SK.UTF-8";
          "LC_PAPER" = "sk_SK.UTF-8";
          "LC_TELEPHONE" = "sk_SK.UTF-8";
          "LC_TIME" = "sk_SK.UTF-8";
        };
        "Translations" = {
          "LANGUAGE" = "sk";
        };
      };
      "powerdevilrc" = {
        "AC/Display" = {
          "DimDisplayIdleTimeoutSec" = "-1";
          "DimDisplayWhenIdle" = "false";
          "TurnOffDisplayIdleTimeoutSec" = "-1";
          "TurnOffDisplayWhenIdle" = "false";
        };
        "AC/SuspendAndShutdown" = {
          "AutoSuspendAction" = "0";
        };
      };
      "kiorc" = {
        "Confirmations" = {
          "ConfirmDelete" = "true";
        };
        "Executable scripts" = {
          "behaviourOnLaunch" = "execute";
        };
      };
      "plasmaparc" = {
        "General" = {
          "RaiseMaximumVolume" = "true";
        };
      };
      "plasmashellrc" = {
        "PlasmaViews/Panel 2" = {
          "floating" = "1";
          "panelLengthMode" = "1";
          "panelOpacity" = "2";
          "panelVisibility" = "2";
        };
        "PlasmaViews/Panel 2/Defaults" = {
          "thickness" = "54";
        };
        "PlasmaViews/Panel 28" = {
          "alignment" = "132";
          "floating" = "1";
          "panelLengthMode" = "1";
          "panelOpacity" = "0";
          "panelVisibility" = "2";
        };
        "PlasmaViews/Panel 28/Defaults" = {
          "thickness" = "54";
        };
      };
      "plasma-org.kde.plasma.desktop-appletsrc" = {
        "ActionPlugins/0" = {
          "RightButton;NoModifier" = "org.kde.contextmenu";
        };
        "ActionPlugins/1" = {
          "RightButton;NoModifier" = "org.kde.contextmenu";
        };
        "Containments/1" = {
          "activityId" = "e6547282-899b-4fc5-81a5-01a68f55408a";
          "formfactor" = "0";
          "immutability" = "1";
          "lastScreen" = "0";
          "location" = "0";
          "plugin" = "org.kde.plasma.folder";
          "wallpaperplugin" = "de.unkn0wn.htmlwallpaper";
        };
        "Containments/1/General" = {
          "sortMode" = "-1";
        };
        "Containments/1/Wallpaper/de.unkn0wn.htmlwallpaper/General" = {
          "DisplayPage" = "file:///home/tachi/bckg/index.html";
          "InsecureHTTPS" = "true";
        };
        "Containments/1/Wallpaper/org.kde.image/General" = {
          "Image" = "/run/media/tachi/MAIN_SYSTEM/Users/olive/OneDrive/Pictures/SoreyMikleo.png";
        };
        "Containments/2" = {
          "activityId" = "";
          "formfactor" = "2";
          "immutability" = "1";
          "lastScreen" = "0";
          "location" = "4";
          "plugin" = "org.kde.panel";
          "wallpaperplugin" = "org.kde.image";
        };
        "Containments/2/Applets/18" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.digitalclock";
        };
        "Containments/2/Applets/18/Configuration/Appearance" = {
          "fontWeight" = "400";
        };
        "Containments/2/Applets/19" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.showdesktop";
        };
        "Containments/2/Applets/24" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.kickoff";
        };
        "Containments/2/Applets/26" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.icontasks";
        };
        "Containments/2/Applets/26/Configuration/General" = {
          "launchers" = "applications:systemsettings.desktop,preferred://browser,preferred://filemanager,applications:com.obsproject.Studio.desktop,applications:toggle.desktop";
          "showOnlyCurrentScreen" = "true";
        };
        "Containments/2/Applets/4" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.pager";
        };
        "Containments/2/Applets/6" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.marginsseparator";
        };
        "Containments/2/Applets/7" = {
          "activityId" = "";
          "formfactor" = "2";
          "immutability" = "1";
          "lastScreen" = "0";
          "location" = "4";
          "plugin" = "org.kde.plasma.systemtray";
          "wallpaperplugin" = "org.kde.image";
        };
        "Containments/2/Applets/7/Applets/10" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.manage-inputmethod";
        };
        "Containments/2/Applets/7/Applets/11" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.devicenotifier";
        };
        "Containments/2/Applets/7/Applets/12" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.clipboard";
        };
        "Containments/2/Applets/7/Applets/13" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.cameraindicator";
        };
        "Containments/2/Applets/7/Applets/14" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.keyboardlayout";
        };
        "Containments/2/Applets/7/Applets/15" = {
          "immutability" = "1";
          "plugin" = "org.kde.kscreen";
        };
        "Containments/2/Applets/7/Applets/16" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.keyboardindicator";
        };
        "Containments/2/Applets/7/Applets/17" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.volume";
        };
        "Containments/2/Applets/7/Applets/20" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.brightness";
        };
        "Containments/2/Applets/7/Applets/21" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.battery";
        };
        "Containments/2/Applets/7/Applets/22" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.mediacontroller";
        };
        "Containments/2/Applets/7/Applets/27" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.weather";
        };
        "Containments/2/Applets/7/Applets/28" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.bluetooth";
        };
        "Containments/2/Applets/7/Applets/9" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.notifications";
        };
        "Containments/2/Applets/7/General" = {
          "extraItems" = "org.kde.plasma.notifications,org.kde.plasma.manage-inputmethod,org.kde.plasma.devicenotifier,org.kde.plasma.mediacontroller,org.kde.plasma.brightness,org.kde.plasma.clipboard,org.kde.plasma.cameraindicator,org.kde.plasma.battery,org.kde.plasma.keyboardlayout,org.kde.kscreen,org.kde.plasma.keyboardindicator,org.kde.plasma.volume,org.kde.plasma.weather,org.kde.plasma.bluetooth";
          "knownItems" = "org.kde.plasma.notifications,org.kde.plasma.manage-inputmethod,org.kde.plasma.devicenotifier,org.kde.plasma.mediacontroller,org.kde.plasma.brightness,org.kde.plasma.clipboard,org.kde.plasma.cameraindicator,org.kde.plasma.battery,org.kde.plasma.keyboardlayout,org.kde.kscreen,org.kde.plasma.keyboardindicator,org.kde.plasma.volume,org.kde.plasma.weather,org.kde.plasma.bluetooth";
        };
        "Containments/2/General" = {
          "AppletOrder" = "24;4;26;6;7;18;19";
        };
        "Containments/20" = {
          "ItemGeometries-1920x1080" = "Applet-57:0,0,320,240,0;Applet-55:0,256,320,240,0;Applet-54:1648,0,272,240,0;Applet-56:0,512,320,240,0;Applet-59:1648,256,272,240,0;Applet-58:1648,512,272,240,0;Applet-63:0,768,320,240,0;Applet-60:1648,768,272,240,0;";
          "ItemGeometries-2259x1271" = "Applet-57:0,0,320,240,0;Applet-55:0,256,320,240,0;Applet-54:1648,0,272,240,0;Applet-56:0,512,320,240,0;Applet-59:1648,256,272,240,0;Applet-58:1648,512,272,240,0;Applet-63:0,768,320,240,0;Applet-60:1648,768,272,240,0;";
          "ItemGeometries-3840x2160" = "Applet-57:0,0,320,240,0;Applet-55:0,256,320,240,0;Applet-54:1648,0,272,240,0;Applet-56:0,544,320,240,0;Applet-59:1648,256,272,240,0;Applet-58:1648,544,272,240,0;Applet-63:0,800,320,240,0;Applet-60:1648,800,272,240,0;";
          "ItemGeometriesHorizontal" = "Applet-57:0,0,320,240,0;Applet-55:0,256,320,240,0;Applet-54:1648,0,272,240,0;Applet-56:0,512,320,240,0;Applet-59:1648,256,272,240,0;Applet-58:1648,512,272,240,0;Applet-63:0,768,320,240,0;Applet-60:1648,768,272,240,0;";
          "activityId" = "e6547282-899b-4fc5-81a5-01a68f55408a";
          "formfactor" = "0";
          "immutability" = "1";
          "lastScreen" = "1";
          "location" = "0";
          "plugin" = "org.kde.plasma.folder";
          "wallpaperplugin" = "de.unkn0wn.htmlwallpaper";
        };
        "Containments/20/Applets/54" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.systemmonitor.cpu";
        };
        "Containments/20/Applets/54/Configuration" = {
          "CurrentPreset" = "org.kde.plasma.systemmonitor";
        };
        "Containments/20/Applets/54/Configuration/Appearance" = {
          "chartFace" = "org.kde.ksysguard.piechart";
          "title" = "Celkové využitie CPU";
        };
        "Containments/20/Applets/54/Configuration/SensorColors" = {
          "cpu/all/usage" = "61,174,233";
          "cpu/cpu0/usage" = "61,174,233";
          "cpu/cpu1/usage" = "61,137,233";
          "cpu/cpu10/usage" = "233,61,149";
          "cpu/cpu11/usage" = "233,61,113";
          "cpu/cpu12/usage" = "233,61,76";
          "cpu/cpu13/usage" = "233,83,61";
          "cpu/cpu14/usage" = "233,120,61";
          "cpu/cpu15/usage" = "233,157,61";
          "cpu/cpu16/usage" = "233,194,61";
          "cpu/cpu17/usage" = "233,231,61";
          "cpu/cpu18/usage" = "199,233,61";
          "cpu/cpu19/usage" = "162,233,61";
          "cpu/cpu2/usage" = "61,100,233";
          "cpu/cpu20/usage" = "125,233,61";
          "cpu/cpu21/usage" = "88,233,61";
          "cpu/cpu22/usage" = "61,233,71";
          "cpu/cpu23/usage" = "61,233,108";
          "cpu/cpu24/usage" = "61,233,145";
          "cpu/cpu25/usage" = "61,233,181";
          "cpu/cpu26/usage" = "61,233,218";
          "cpu/cpu27/usage" = "61,211,233";
          "cpu/cpu3/usage" = "61,63,233";
          "cpu/cpu4/usage" = "95,61,233";
          "cpu/cpu5/usage" = "132,61,233";
          "cpu/cpu6/usage" = "169,61,233";
          "cpu/cpu7/usage" = "206,61,233";
          "cpu/cpu8/usage" = "233,61,223";
          "cpu/cpu9/usage" = "233,61,186";
          "cpu/cpu\\d+/usage" = "115,61,233";
        };
        "Containments/20/Applets/54/Configuration/Sensors" = {
          "highPrioritySensorIds" = "[\"cpu/cpu\\\\\\\\d+/usage\"]";
          "lowPrioritySensorIds" = "[\"cpu/all/cpuCount\",\"cpu/all/coreCount\"]";
          "totalSensors" = "[\"cpu/all/usage\"]";
        };
        "Containments/20/Applets/54/Configuration/org.kde.ksysguard.piechart/General" = {
          "showLegend" = "false";
        };
        "Containments/20/Applets/55" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.systemmonitor.diskactivity";
        };
        "Containments/20/Applets/55/Configuration" = {
          "CurrentPreset" = "org.kde.plasma.systemmonitor";
        };
        "Containments/20/Applets/55/Configuration/Appearance" = {
          "chartFace" = "org.kde.ksysguard.linechart";
          "title" = "Aktivita pevného disku";
        };
        "Containments/20/Applets/55/Configuration/SensorColors" = {
          "disk/all/read" = "233,120,61";
          "disk/all/write" = "61,174,233";
        };
        "Containments/20/Applets/55/Configuration/Sensors" = {
          "highPrioritySensorIds" = "[\"disk/all/write\",\"disk/all/read\"]";
        };
        "Containments/20/Applets/56" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.systemmonitor.memory";
        };
        "Containments/20/Applets/56/Configuration" = {
          "CurrentPreset" = "org.kde.plasma.systemmonitor";
        };
        "Containments/20/Applets/56/Configuration/Appearance" = {
          "chartFace" = "org.kde.ksysguard.linechart";
          "title" = "Využitie pamäte";
        };
        "Containments/20/Applets/56/Configuration/SensorColors" = {
          "memory/physical/used" = "61,174,233";
        };
        "Containments/20/Applets/56/Configuration/Sensors" = {
          "highPrioritySensorIds" = "[\"memory/physical/used\"]";
          "lowPrioritySensorIds" = "[\"memory/physical/total\"]";
          "totalSensors" = "[\"memory/physical/usedPercent\"]";
        };
        "Containments/20/Applets/56/Configuration/org.kde.ksysguard.linechart/General" = {
          "showLegend" = "false";
        };
        "Containments/20/Applets/57" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.systemmonitor.net";
        };
        "Containments/20/Applets/57/Configuration" = {
          "CurrentPreset" = "org.kde.plasma.systemmonitor";
        };
        "Containments/20/Applets/57/Configuration/Appearance" = {
          "chartFace" = "org.kde.ksysguard.linechart";
          "title" = "Rýchlosť siete";
        };
        "Containments/20/Applets/57/Configuration/SensorColors" = {
          "network/all/download" = "61,174,233";
          "network/all/upload" = "233,120,61";
        };
        "Containments/20/Applets/57/Configuration/Sensors" = {
          "highPrioritySensorIds" = "[\"network/all/download\",\"network/all/upload\"]";
        };
        "Containments/20/Applets/58" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.systemmonitor.cpu";
        };
        "Containments/20/Applets/58/Configuration" = {
          "CurrentPreset" = "org.kde.plasma.systemmonitor";
        };
        "Containments/20/Applets/58/Configuration/Appearance" = {
          "chartFace" = "org.kde.ksysguard.piechart";
          "title" = "Celkové využitie GPU";
        };
        "Containments/20/Applets/58/Configuration/SensorColors" = {
          "cpu/all/usage" = "61,174,233";
          "gpu/all/usage" = "233,61,215";
        };
        "Containments/20/Applets/58/Configuration/Sensors" = {
          "highPrioritySensorIds" = "[\"gpu/all/usage\"]";
          "lowPrioritySensorIds" = "[]";
          "totalSensors" = "[\"gpu/all/usage\"]";
        };
        "Containments/20/Applets/58/Configuration/org.kde.ksysguard.piechart/General" = {
          "showLegend" = "false";
        };
        "Containments/20/Applets/59" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.systemmonitor.cpu";
        };
        "Containments/20/Applets/59/Configuration" = {
          "CurrentPreset" = "org.kde.plasma.systemmonitor";
        };
        "Containments/20/Applets/59/Configuration/Appearance" = {
          "chartFace" = "org.kde.ksysguard.linechart";
          "title" = "Teplota CPU";
        };
        "Containments/20/Applets/59/Configuration/SensorColors" = {
          "cpu/all/averageTemperature" = "233,231,61";
          "cpu/all/usage" = "61,174,233";
        };
        "Containments/20/Applets/59/Configuration/Sensors" = {
          "highPrioritySensorIds" = "[\"cpu/all/averageTemperature\"]";
          "lowPrioritySensorIds" = "[\"cpu/all/cpuCount\",\"cpu/all/coreCount\"]";
          "totalSensors" = "[\"cpu/all/usage\"]";
        };
        "Containments/20/Applets/59/Configuration/org.kde.ksysguard.linechart/General" = {
          "showLegend" = "false";
        };
        "Containments/20/Applets/60" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.systemmonitor.cpu";
        };
        "Containments/20/Applets/60/Configuration" = {
          "CurrentPreset" = "org.kde.plasma.systemmonitor";
        };
        "Containments/20/Applets/60/Configuration/Appearance" = {
          "chartFace" = "org.kde.ksysguard.linechart";
          "title" = "Teplota GPU";
        };
        "Containments/20/Applets/60/Configuration/SensorColors" = {
          "cpu/all/usage" = "61,174,233";
          "gpu/gpu1/temperature" = "233,61,101";
        };
        "Containments/20/Applets/60/Configuration/Sensors" = {
          "highPrioritySensorIds" = "[\"gpu/gpu1/temperature\"]";
          "lowPrioritySensorIds" = "[\"cpu/all/cpuCount\",\"cpu/all/coreCount\"]";
          "totalSensors" = "[\"cpu/all/usage\"]";
        };
        "Containments/20/Applets/63" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.volume";
        };
        "Containments/20/Wallpaper/de.unkn0wn.htmlwallpaper/General" = {
          "DisplayPage" = "file:///home/tachi/bckg/index.html";
          "InsecureHTTPS" = "true";
        };
        "Containments/20/Wallpaper/org.kde.image/General" = {
          "DynamicMode" = "1";
          "FillMode" = "1";
          "Image" = "file:///home/tachi/Documents/SoreyMikleo.png";
        };
        "Containments/28" = {
          "activityId" = "";
          "formfactor" = "2";
          "immutability" = "1";
          "lastScreen" = "1";
          "location" = "4";
          "plugin" = "org.kde.panel";
          "wallpaperplugin" = "org.kde.image";
        };
        "Containments/28/Applets/29" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.pager";
        };
        "Containments/28/Applets/30" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.marginsseparator";
        };
        "Containments/28/Applets/31" = {
          "activityId" = "";
          "formfactor" = "0";
          "immutability" = "1";
          "lastScreen" = "-1";
          "location" = "0";
          "plugin" = "org.kde.plasma.systemtray";
          "wallpaperplugin" = "org.kde.image";
        };
        "Containments/28/Applets/31/Applets/22" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.mediacontroller";
        };
        "Containments/28/Applets/31/Applets/28" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.bluetooth";
        };
        "Containments/28/Applets/31/Applets/32" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.manage-inputmethod";
        };
        "Containments/28/Applets/31/Applets/33" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.clipboard";
        };
        "Containments/28/Applets/31/Applets/34" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.cameraindicator";
        };
        "Containments/28/Applets/31/Applets/35" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.keyboardlayout";
        };
        "Containments/28/Applets/31/Applets/36" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.notifications";
        };
        "Containments/28/Applets/31/Applets/37" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.devicenotifier";
        };
        "Containments/28/Applets/31/Applets/38" = {
          "immutability" = "1";
          "plugin" = "org.kde.kscreen";
        };
        "Containments/28/Applets/31/Applets/39" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.keyboardindicator";
        };
        "Containments/28/Applets/31/Applets/40" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.volume";
        };
        "Containments/28/Applets/31/Applets/41" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.weather";
        };
        "Containments/28/Applets/31/Applets/42" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.brightness";
        };
        "Containments/28/Applets/31/Applets/43" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.battery";
        };
        "Containments/28/Applets/31/Applets/48" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.mediacontroller";
        };
        "Containments/28/Applets/31/General" = {
          "extraItems" = "org.kde.plasma.notifications,org.kde.plasma.manage-inputmethod,org.kde.plasma.devicenotifier,org.kde.plasma.mediacontroller,org.kde.plasma.brightness,org.kde.plasma.clipboard,org.kde.plasma.cameraindicator,org.kde.plasma.battery,org.kde.plasma.keyboardlayout,org.kde.kscreen,org.kde.plasma.keyboardindicator,org.kde.plasma.volume,org.kde.plasma.weather,org.kde.plasma.bluetooth";
          "knownItems" = "org.kde.plasma.notifications,org.kde.plasma.manage-inputmethod,org.kde.plasma.devicenotifier,org.kde.plasma.mediacontroller,org.kde.plasma.brightness,org.kde.plasma.clipboard,org.kde.plasma.cameraindicator,org.kde.plasma.battery,org.kde.plasma.keyboardlayout,org.kde.kscreen,org.kde.plasma.keyboardindicator,org.kde.plasma.volume,org.kde.plasma.weather,org.kde.plasma.bluetooth";
        };
        "Containments/28/Applets/44" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.digitalclock";
        };
        "Containments/28/Applets/44/Configuration/Appearance" = {
          "fontWeight" = "400";
        };
        "Containments/28/Applets/45" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.showdesktop";
        };
        "Containments/28/Applets/46" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.kickoff";
        };
        "Containments/28/Applets/47" = {
          "immutability" = "1";
          "plugin" = "org.kde.plasma.icontasks";
        };
        "Containments/28/Applets/47/Configuration/General" = {
          "launchers" = "applications:systemsettings.desktop,preferred://filemanager,applications:com.obsproject.Studio.desktop,applications:toggle.desktop,preferred://browser";
          "showOnlyCurrentScreen" = "true";
        };
        "Containments/28/General" = {
          "AppletOrder" = "46;29;47;30;31;44;45";
        };
      };
      "katerc" = {
        "General" = {
          "Days Meta Infos" = "30";
          "Save Meta Infos" = "true";
          "Show Full Path in Title" = "false";
          "Show Menu Bar" = "true";
          "Show Status Bar" = "true";
          "Show Tab Bar" = "true";
          "Show Url Nav Bar" = "true";
        };
        "KTextEditor Renderer" = {
          "Animate Bracket Matching" = "false";
          "Auto Color Theme Selection" = "true";
          "Color Theme" = "Breeze Dark";
          "Line Height Multiplier" = "1";
          "Show Indentation Lines" = "false";
          "Show Whole Bracket Expression" = "false";
          "Text Font" = "Hack,10,-1,7,400,0,0,0,0,0,0,0,0,0,0,1";
          "Word Wrap Marker" = "false";
        };
        "filetree" = {
          "editShade" = "31,81,106";
          "listMode" = "false";
          "middleClickToClose" = "false";
          "shadingEnabled" = "true";
          "showCloseButton" = "false";
          "showFullPathOnRoots" = "false";
          "showToolbar" = "true";
          "sortRole" = "0";
          "viewShade" = "81,49,95";
        };
      };
      "kwriterc" = {
        "General" = {
          "Days Meta Infos" = "30";
          "Save Meta Infos" = "true";
          "Show Full Path in Title" = "false";
          "Show Menu Bar" = "false";
          "Show Status Bar" = "true";
          "Show Tab Bar" = "true";
          "Show Url Nav Bar" = "false";
        };
      };
      "dolphinrc" = {
        "IconsMode" = {
          "PreviewSize" = "80";
        };
      };
      "spectaclerc" = {
        "General" = {
          "clipboardGroup" = "PostScreenshotCopyImage";
        };
        "GuiConfig" = {
          "captureMode" = "0";
        };
        "ImageSave" = {
          "translatedScreenshotsFolder" = "Screenshots";
        };
        "VideoSave" = {
          "translatedScreencastsFolder" = "Screencasts";
        };
      };
    };
  };

  # DISCOVERED MIME defaults; browser profiles/auth remain outside Nix.
  xdg.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "text/html" = [ "brave-browser.desktop" ];
      "x-scheme-handler/curseforge" = [ "curseforge.desktop" ];
      "x-scheme-handler/cfauth" = [ "curseforge.desktop" ];
    };
    associations.added."x-scheme-handler/cfauth" = [ "curseforge.desktop" ];
  };

  # DISCOVERED directory names, including the custom Projects directory.
  xdg.userDirs = {
    enable = true;
    createDirectories = false; # REVIEW: capture paths without assuming directory creation.
    desktop = "/home/tachi/Desktop";
    download = "/home/tachi/Downloads";
    templates = "/home/tachi/Templates";
    publicShare = "/home/tachi/Public";
    documents = "/home/tachi/Documents";
    music = "/home/tachi/Music";
    pictures = "/home/tachi/Pictures";
    videos = "/home/tachi/Videos";
    extraConfig.XDG_PROJECTS_DIR = "/home/tachi/Projekty";
  };

  # DISCOVERED static text snapshots. Partial files explicitly exclude mutable
  # state; before activation choose whole-file ownership vs a merging mechanism.
  # No force=true: existing file collision handling/backup is a Phase 12 decision.
  xdg.configFile = {
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=true
      gtk-button-images=true
      gtk-cursor-blink=true
      gtk-cursor-blink-time=1000
      gtk-cursor-theme-name=breeze_cursors
      gtk-cursor-theme-size=24
      gtk-decoration-layout=icon:minimize,maximize,close
      gtk-enable-animations=true
      gtk-font-name=Noto Sans,  10
      gtk-icon-theme-name=breeze-dark
      gtk-menu-images=true
      gtk-modules=colorreload-gtk-module
      gtk-primary-button-warps-slider=true
      gtk-sound-theme-name=ocean
      gtk-theme-name=
      gtk-toolbar-style=3
      gtk-xft-dpi=196608
    '';
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=true
      gtk-cursor-blink=true
      gtk-cursor-blink-time=1000
      gtk-cursor-theme-name=breeze_cursors
      gtk-cursor-theme-size=24
      gtk-decoration-layout=icon:minimize,maximize,close
      gtk-enable-animations=true
      gtk-font-name=Noto Sans,  10
      gtk-icon-theme-name=breeze-dark
      gtk-modules=colorreload-gtk-module
      gtk-primary-button-warps-slider=true
      gtk-sound-theme-name=ocean
      gtk-theme-name=
      gtk-xft-dpi=196608
    '';
    "MangoHud/MangoHud.conf".text = ''
      fps_limit=0+60+120
      toggle_fps_limit=Shift_L+F1
      toggle_hud=Shift_L+F10

      horizontal
      table_columns=4
      font_size=28

      time
      time_format=%d.%m.%Y %H:%M
      cpu_stats
      cpu_temp
      cpu_mhz
      gpu_stats
      gpu_temp
      gpu_core_clock
      ram
      procmem
      vram
      fps
      frame_timing
    '';
    "Code/User/settings.json".text = ''
      {
          "cmake.options.statusBarVisibility": "visible",
          "cmake.pinnedCommands": [
              "workbench.action.tasks.configureTaskRunner",
              "workbench.action.tasks.runTask"
          ],
          "cmake.showOptionsMovedNotification": false,
          "git.enableSmartCommit": true,
          "git.autofetch": true,
          "explorer.confirmDragAndDrop": false
      }'';
    "autostart/steam.desktop".text = ''
      [Desktop Entry]
      Actions=Store;Community;Library;Servers;Screenshots;News;Settings;BigPicture;Friends;
      Categories=Network;FileTransfer;Game;
      Comment[sk_SK]=Application for managing and playing games on Steam
      Comment=Application for managing and playing games on Steam
      Exec=steam %U
      GenericName[sk_SK]=
      GenericName=
      Icon=steam
      MimeType=
      Name[sk_SK]=Steam
      Name=Steam
      Path=
      PrefersNonDefaultGPU=true
      StartupNotify=true
      Terminal=false
      TerminalOptions=
      Type=Application
      X-KDE-RunOnDiscreteGpu=true
      X-KDE-SubstituteUID=false
      X-KDE-Username=

      [Desktop Action BigPicture]
      Exec=steam steam://open/bigpicture
      Name=Big Picture

      [Desktop Action Community]
      Exec=steam steam://url/CommunityHome/
      Name=Community

      [Desktop Action Friends]
      Exec=steam steam://open/friends
      Name=Friends

      [Desktop Action Library]
      Exec=steam steam://open/games
      Name=Library

      [Desktop Action News]
      Exec=steam steam://openurl/https://store.steampowered.com/news
      Name=News

      [Desktop Action Screenshots]
      Exec=steam steam://open/screenshots
      Name=Screenshots

      [Desktop Action Servers]
      Exec=steam steam://open/servers
      Name=Servers

      [Desktop Action Settings]
      Exec=steam steam://open/settings
      Name=Settings

      [Desktop Action Store]
      Exec=steam steam://store
      Name=Store
    '';
    "autostart/discord.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Exec=/nix/store/hw3w8mkz3bzmfarlcga6xa8g135i306i-discord-1.0.159/opt/Discord/.Discord-wrapped
      Hidden=false
      NoDisplay=false
      Name=.Discord-wrapped
      Icon=/nix/store/hw3w8mkz3bzmfarlcga6xa8g135i306i-discord-1.0.159/opt/Discord/discord.png
      Comment=Text and voice chat for gamers.
      X-GNOME-Autostart-enabled=true
    '';
    "autostart/lunarclient.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Version=1.0
      Name=lunarclient
      Comment=lunarclientstartup script
      Exec=/home/tachi/.cache/appimage-run/248b29f041a39120d03232931a0d44dc0f713183f0e256efbec23af427e9ff3d/lunarclient --hidden
      StartupNotify=false
      Terminal=false'';
    "htop/htoprc".text = ''
      # Beware! This file is rewritten by htop when settings are changed in the interface.
      # The parser is also very primitive, and not human-friendly.
      htop_version=3.5.1
      config_reader_min_version=3
      fields=0 48 17 18 38 39 40 2 46 47 49 1
      hide_kernel_threads=1
      hide_userland_threads=0
      hide_running_in_container=0
      shadow_other_users=0
      show_thread_names=0
      show_program_path=1
      highlight_base_name=0
      highlight_deleted_exe=1
      shadow_distribution_path_prefix=0
      highlight_megabytes=1
      highlight_threads=1
      highlight_changes=0
      highlight_changes_delay_secs=5
      find_comm_in_cmdline=1
      strip_exe_from_cmdline=1
      show_merged_command=0
      header_margin=1
      screen_tabs=1
      detailed_cpu_time=0
      cpu_count_from_one=0
      show_cpu_smt_labels=0
      show_cpu_usage=1
      show_cpu_frequency=0
      show_cpu_temperature=1
      degree_fahrenheit=0
      show_cached_memory=1
      update_process_names=0
      account_guest_in_cpu_meter=0
      color_scheme=0
      enable_mouse=1
      delay=15
      hide_function_bar=0
      header_layout=two_50_50
      column_meters_0=LeftCPUs4 Memory Swap
      column_meter_modes_0=1 1 1
      column_meters_1=RightCPUs4 Tasks LoadAverage Uptime
      column_meter_modes_1=1 2 2 2
      tree_view=0
      sort_key=47
      tree_sort_key=0
      sort_direction=-1
      tree_sort_direction=1
      tree_view_always_by_pid=0
      all_branches_collapsed=0
      screen:Main=PID USER PRIORITY NICE M_VIRT M_RESIDENT M_SHARE STATE PERCENT_CPU PERCENT_MEM TIME Command
      .sort_key=PERCENT_MEM
      .tree_sort_key=PID
      .tree_view_always_by_pid=0
      .tree_view=0
      .sort_direction=-1
      .tree_sort_direction=1
      .all_branches_collapsed=0
      screen:I/O=PID USER IO_PRIORITY IO_RATE IO_READ_RATE IO_WRITE_RATE PERCENT_SWAP_DELAY PERCENT_IO_DELAY Command
      .sort_key=IO_RATE
      .tree_sort_key=PID
      .tree_view_always_by_pid=0
      .tree_view=0
      .sort_direction=-1
      .tree_sort_direction=1
      .all_branches_collapsed=0
    '';
    "noisetorch/config.toml".text = ''
      Threshold = 10
      DisplayMonitorSources = false
      EnableUpdates = true
      FilterInput = true
      FilterOutput = false
      LastUsedInput = "alsa_input.usb-3142_fifine_Microphone-00.analog-stereo"
      LastUsedOutput = ""
    '';
    "JetBrains/CLion2026.2/options/editor.xml".text = ''
      <application>
        <component name="CodeInsightSettings">
          <option name="AUTO_POPUP_JAVADOC_INFO" value="true" />
        </component>
      </application>'';
    "JetBrains/CLion2026.2/options/colors.scheme.xml".text = ''
      <application>
        <component name="EditorColorsManagerImpl">
          <global_color_scheme name="Islands Dark" />
        </component>
      </application>'';
    "JetBrains/CLion2026.2/options/linux/keymap.xml".text = ''
      <application>
        <component name="KeymapManager">
          <active_keymap name="VSCode" />
        </component>
      </application>'';
    # PARTIAL: excludes selected scene/profile and window layout.
    "obs-studio/user.ini".text = ''
      [General]
      MaxLogs=10
      ProcessPriority=Normal
      EnableAutoUpdates=true
      ConfirmOnExit=true
      HotkeyFocusType=NeverDisableHotkeys

      [Video]
      Renderer=OpenGL

      [BasicWindow]
      PreviewEnabled=true
      PreviewProgramMode=false
      SceneDuplicationMode=true
      SwapScenesMode=true
      SnappingEnabled=true
      ScreenSnapping=true
      SourceSnapping=true
      CenterSnapping=false
      SnapDistance=0.0
      SpacingHelpersEnabled=true
      RecordWhenStreaming=false
      KeepRecordingWhenStreamStops=false
      SysTrayEnabled=true
      SysTrayWhenStarted=false
      SaveProjectors=false
      ShowTransitions=true
      ShowListboxToolbars=true
      ShowStatusBar=true
      ShowSourceIcons=true
      ShowContextToolbars=true
      StudioModeLabels=true
      VerticalVolControl=false
      MultiviewMouseSwitch=true
      MultiviewDrawNames=true
      MultiviewDrawAreas=true
      MediaControlsCountdownTimer=true
      AlwaysOnTop=false
      EditPropertiesMode=false
      DocksLocked=false
      SideDocks=false
      WarnBeforeStartingStream=false
      WarnBeforeStoppingStream=false
      WarnBeforeStoppingRecord=false
      VerticalVolumeControl=true
      MixerShowInactive=false
      MixerKeepInactiveLast=false
      MixerShowHidden=false
      MixerKeepHiddenLast=false

      [Appearance]
      FontScale=10
      Density=1

      [Accessibility]
      SelectRed=255
      SelectGreen=65280
      SelectBlue=16744192
      MixerGreen=2522918
      MixerYellow=2523007
      MixerRed=2500223
      MixerGreenActive=5046092
      MixerYellowActive=5046271
      MixerRedActive=5000447

    '';
    # PARTIAL: ports/cookies/torrent state intentionally NOT declared.
    "qBittorrent/qBittorrent.conf".text = ''
      [BitTorrent]
      Session\QueueingSystemEnabled=false

      [GUI]
      Log\Enabled=false

    '';
    "vlc/vlcrc".text = ''
      [qt]
      qt-privacy-ask=0
    '';
    # PARTIAL: selected settings only; GUI rewrites config on exit.
    "retroarch/retroarch.cfg".text = ''
      audio_driver = "pulse"
      config_save_on_exit = "true"
      fps_show = "false"
      input_joypad_driver = "udev"
      menu_driver = "ozone"
      savestate_auto_index = "false"
      savestate_auto_load = "false"
      savestate_auto_save = "false"
      video_driver = "vulkan"
      video_fullscreen = "false"
      video_vsync = "true"
    '';
  };

  # DISCOVERED .zshrc captured exactly: this preserves the existing system Zsh
  # ownership and startup ordering; native programs.zsh would require reviewing
  # system Oh My Zsh, completion and direnv hooks to avoid duplicate setup.
  # compinit and fastfetch already run here; no user aliases/exports are invented.
  home.file = {
    ".zshrc" = {
      text = ''
        # Lines configured by zsh-newuser-install
        HISTFILE=~/.histfile
        HISTSIZE=1000
        SAVEHIST=1000
        bindkey -e
        # End of lines configured by zsh-newuser-install
        # The following lines were added by compinstall
        zstyle :compinstall filename '/home/tachi/.zshrc'

        autoload -Uz compinit
        compinit
        # End of lines added by compinstall

        fastfetch
      '';
      executable = true;
    };
    ".gtkrc-2.0" = {
      text = ''
        gtk-cursor-blink-time=1000
        gtk-cursor-blink=1
        gtk-enable-animations=1
        gtk-theme-name=""
        gtk-primary-button-warps-slider=1
        gtk-toolbar-style=3
        gtk-menu-images=1
        gtk-button-images=1
        gtk-cursor-theme-size=24
        gtk-cursor-theme-name="breeze_cursors"
        gtk-sound-theme-name="ocean"
        gtk-icon-theme-name="breeze-dark"
        gtk-font-name="Noto Sans,  10"

      '';
    };
    "toggle-screen.sh" = {
      text = ''
        #!/bin/sh

        # Nastavenia (uprav si podľa reality)
        LEFT="DP-2"
        RIGHT="DP-3" # <--- SEM DAJ NÁZOV SVOJHO HLAVNÉHO MONITORA
        WIDTH="1920"     # <--- SEM DAJ ŠÍRKU TOHO ĽAVÉHO MONITORA

        if kscreen-doctor -o | grep -A 1 "$LEFT" | grep -q "enabled"; then
            kscreen-doctor output.$LEFT.disable
        else
            # Mágia: Ľavý ide na 0,0 a pravý sa posunie presne za neho
            kscreen-doctor output.$LEFT.enable position.0,0 \
                           output.$RIGHT.position.$WIDTH,0
        fi
      '';
      executable = true;
    };
    "androidshell.sh" = {
      text = ''
        nix-shell -p android-tools
      '';
      executable = true;
    };
    "ea-env-wrapper.sh" = {
      text = ''
        # Trim long env vars
        for var in $(printenv | awk 'length($0) > 2048' | cut -d= -f1); do
            export $var=$(echo "''${!var}" | rev | cut -c1-1000 | rev)
        done

        # Now call real Wine
        exec "$@"
      '';
      executable = true;
    };
    "grubswitcher.sh" = {
      text = ''
        sudo /root/grubswitcher.sh
      '';
    };
    "bckg/index.html" = {
      text = "<html>\n\t<head>\n\t\t<style>\n\t\t\t.parent{\n\t\t\t\tbackground-size: cover;\n\t\t\t\tbackground-position: center;\n\t\t\t\tbackground-repeat: no-repeat;\n\t\t\t\tposition: absolute;\n\t\t\t\tinset: 0;\n\t\t\t}\n\t\t\t.img-sorey {\n\t\t\t\twidth: 100%;\n\t\t\t\theight: 100%;\n\t\t\t\tobject-fit: contain;\n\t\t\t\tobject-position: bottom left;\n\t\t\t}\n\t\t\t.sorey{\n\t\t\t\tposition: absolute;\n\t\t\t\tbottom: 0;\n\t\t\t\tleft: 0;\n\t\t\t\theight: 97vh;\n    \t\t\twidth: 60vw;\n\t\t\t\t-webkit-transition: all 0.3s linear;\n\t\t\t\t\t\ttransition: all 0.3s linear;\n\t\t\t\t-webkit-transform: scale3d(1, 1, 1);\n\t\t\t\t\t\ttransform: scale3d(1, 1, 1);\n\t\t\t}\n\t\t\t.sorey:hover{\n\t\t\t\ttransform: scale3d(1.05, 1.05, 1);\n\t\t\t}\n\t\t\t.mikleo{\n\t\t\t\tposition: absolute;\n\t\t\t\tbottom: 0;\n\t\t\t\tright: 0;\n\t\t\t\theight: 92vh;\n    \t\t\twidth: 40vw;\n\t\t\t\t-webkit-transition: all 0.3s linear;\n\t\t\t\t\t\ttransition: all 0.3s linear;\n\t\t\t\t-webkit-transform: scale3d(1, 1, 1);\n\t\t\t\t\t\ttransform: scale3d(1, 1, 1);\n\t\t\t}\n\t\t\t.img-mikleo {\n\t\t\t\twidth: 100%;\n\t\t\t\theight: 100%;\n\t\t\t\tobject-fit: contain;\n\t\t\t\tobject-position: bottom right;\n\t\t\t}\n\t\t\t.mikleo:hover{\n\t\t\t\ttransform: scale3d(1.05, 1.05, 1);\n\t\t\t}\n\t\t\t.bgnight{\n\t\t\t\twidth: 100%;\n\t\t\t\theight: 100%;\n\t\t\t\tposition: absolute;\n\t\t\t\tinset: 0;\n\t\t\t\tobject-fit: cover;\n\t\t\t}\n\t\t\t.bgday{\n\t\t\t\twidth: 100%;\n\t\t\t\theight: 100%;\n\t\t\t\tposition: absolute;\n\t\t\t\tinset: 0;\n\t\t\t\tobject-fit: cover;\n\t\t\t\t\t-webkit-transition: all 1s linear;\n\t\t\t\t\t\t\ttransition: all 1s linear;\n\t\t\t}\n\t\t</style>\n\t\t<script src=\"https://unpkg.com/suncalc@1.9.0/suncalc.js\"></script>\n\t\t<script>\n\t\t\tsetTimeout(changeImage, 10);\n\t\t\tfunction changeImage()\n\t\t\t{\n\t\t\tconst times = SunCalc.getTimes(new Date(), 48.1486, 17.1077);\n\t\t\t\tvar now = new Date();\n\t\t\t\tvar element = document.getElementById(\"Day\");\n\t\t\t\tif ((now < times.sunrise || now > times.sunset) && element.style.opacity != \"0\")\n\t\t\t\t{\n\t\t\t\t\telement.style.opacity=\"0\";\n\t\t\t\t}\n\t\t\t\tif ((now >= times.sunrise && now <= times.sunset) && element.style.opacity != \"1\")\n\t\t\t\t{\n\t\t\t\t\telement.style.opacity=\"1\";\n\t\t\t\t}\n\t\t\t\tsetTimeout(changeImage, 30000);\n\t\t\t}\n\t\t</script>\n\t\t<title>Sorey & Mikleo Wallpaper</title>\n\t</head>\n\t<body style=\"overflow: hidden\">\n\t\t<div class=\"parent\"/>\n\t\t\t<img src=\"Background-Night.png\" class=\"bgnight\">\n\t\t\t<img src=\"Background-Day.png\" class=\"bgday\" id=\"Day\">\n\t\t\t<div class=\"sorey\">\n\t\t\t\t<img src=\"Sorey.png\" class=\"img-sorey\"/>\n\t\t\t</div>\n\t\t\t<div class=\"mikleo\">\n\t\t\t\t<img src=\"Mikleo.png\" class=\"img-mikleo\"/>\n\t\t\t</div>\n\t\t</div>\n\t</body>\n</html>";
    };
    ".local/share/applications/toggle.desktop" = {
      text = ''
        [Desktop Entry]
        Name=Toggle Left Monitor
        Exec=~/toggle-screen.sh
        Icon=video-display
        Type=Application
        Terminal=false
        Categories=Utility;
      '';
    };
    ".local/share/applications/restart-to-windows.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Restart to Windows
        Icon=system-reboot
        Exec=sudo /root/grub-switcher.sh
        Categories=System
        Terminal=false
      '';
      executable = true;
    };
  };
}

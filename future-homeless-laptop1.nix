# INACTIVE Phase 10 Laptop extraction; observed 2026-11-14 on hostname Laptop.
# User data: /home/tachi. Tool process was root; no login shell was sourced.
# This is a single-file snapshot for Phase 11 comparison, NOT imported anywhere.
# Requires Home Manager plus the Plasma Manager module in a future reviewed setup.
# Deliberately no imports, package selection, activation hooks or stateVersion.
# Choose home.stateVersion for the first actual HM installation in Phase 12;
# the NixOS installation stateVersion is not evidence for an HM stateVersion.
# All values below were found on disk, including possible application defaults;
# presence does not prove deliberate preference or that a running app loaded it.
# No settings were queried by launching applications; no live files were changed.
#
# Ownership retained by NixOS (do not duplicate during comparison):
# modules/common/shell.nix: Zsh, agnoster, git/z Oh My Zsh plugins, PATH and
# XDG_CONFIG_HOME. modules/cli/productivity.nix: Git/Codex packages and direnv /
# nix-direnv Zsh integration. modules/gui/session.nix: Plasma 6, portals, SDDM,
# Slovak keyboard, NIXOS_OZONE_WL=1 and MANGOHUD=1. Locale/timezone/fonts,
# accounts, services, SSH server/builder policy and all application packages stay
# in NixOS. modules/gui/development.nix owns VS Code and JetBrains extensions.
# No user aliases or extra exports were present in .zshrc; inherited shell aliases
# and environment were not inferred from the root tool environment.
# No .ssh/config, .bashrc, .bash_profile, .profile, .zprofile, .zshenv, fish config,
# environment.d, user systemd directory, or ~/.local/bin existed at inspection.
# Plasma env/shutdown directories were empty. nixupdate remains the system/repo
# workflow; no personal script was invented. System-generated user units remain
# system-owned. SSH keys/known_hosts/agent state were not copied or examined.
#
# Migration limits / manual review before ANY future use:
# - No activation has been tested. Static HM files become store-backed; applications
#   that rewrite preferences (Zsh/Git/GTK/IDEs/htop) need ownership review/backups.
# - Plasma configFile is used for exact stored KConfig values, avoiding assumptions
#   about high-level enums. Strings preserve KConfig serialization. Converter
#   shortcuts use the active binding field; explicit empty bindings are retained.
# - rc2nix upstream script/rc2nix.py (trunk) was inspected and run without installing
#   anything against sanitized temporary inputs. Its exclusions discard colors,
#   LookAndFeelPackage and panel properties: these were restored from source here.
#   Its default file list also misses panels and powerdevilrc. No generated output
#   was trusted as a complete profile. It cannot extract Konsole's root MenuBar key.
#   Converter source: https://github.com/nix-community/plasma-manager/blob/trunk/script/rc2nix.py
#   SHA256: 904296d8f9bcfe5baa30fbad8669201a4220760f7ddec3b0d0f56d733198fa0d
# - Panel 2: bottom (location=4), floating, 46px; order kickoff, advanced weather,
#   icon tasks, pager, separator, tray, clock, show desktop. Numeric applet/activity
#   IDs and desktop geometries are Laptop-specific; prefer a reviewed native panel
#   declaration after Phase 11. Do not reset an existing layout during migration.
# - Desktop monitors reference eight CPU threads, NVIDIA/Intel GPU sensor IDs and
#   wlp0s20f3: hardware enumeration must be verified on Laptop at runtime.
# - Wallpaper plugin de.unkn0wn.htmlwallpaper needs separate installation and
#   /home/tachi/bckg/index.html/assets; files were NOT copied or inspected. Stored
#   InsecureHTTPS=true is captured, not newly recommended. Screenshot wallpaper
#   paths remain references only. Verify asset availability manually.
# - Advanced weather plasmoid is locally installed; its code was not copied.
#   Weather locations are observed preferences (Handlova and Banska Bystrica),
#   retained for comparison; weather notification/cache state was removed.
#   Other installed third-party plasmoids are not automatically selected/installed.
# - kwinoutputconfig.json is mutable hardware state, deliberately unmanaged:
#   eDP-1 1920x1080 at 60.020Hz scale 1; HDMI-A-1 3840x2160 at 60Hz scale 1.45.
#   Stored setups include HDMI at x=1920,y=0 with replicationSource referencing
#   eDP. That combination is ambiguous: confirm actual mirror/extend behavior.
#   KWin tiling UUIDs remain here solely as observed Laptop layout dependencies.
# - Konsole has no custom .profile or .colorscheme in ~/.local/share/konsole;
#   only menu visibility was found. Do not invent a font/default profile.
# - No VS Code keybindings.json was present. Git smart commit is the sole setting.
#   IDE XML is version-directory-specific (2026.2); code styles/keymaps absent
#   from the audited directories are not invented. Default-font XML has no explicit
#   font choice; omitted. CLion editor.xml contains generated template records and
#   is left for manual template export, rather than freezing its internal schema.
# - ~/.local/share/applications/curseforge.desktop is malformed: it contains shell
#   heredoc wrapper lines. Not repaired in this extraction. MIME handlers refer to
#   both curseforge.desktop and CurseForge.desktop; resolve in Phase 11/12.
#   Game, Wine, browser-webapp and Discord generated launchers remain unmanaged.
# - Browser/Discord/Codex/JetBrains account state, license keys, wallet, tokens,
#   Steam library/saves, VM disks, databases, sessions, recent files, histories,
#   caches and logs excluded. No complete browser/application profile is claimed.
# - RetroArch is a large mixed settings/state file (config_save_on_exit=true);
#   no whole-file ownership proposed. A small explicit preference subset is
#   recorded below for later merging; remaps/core options/games require manual
#   export. qBittorrent, Sunshine, TeamViewer, VirtualBox, LibreOffice, Kodi and
#   Flatpak per-app profiles remain manual follow-up to avoid account/state capture.
#   Midnight Commander mixes editor/panel preferences with connection settings:
#   left unmanaged pending selective migration (internal editor, tab spacing 8,
#   visible tabs/spaces, dotfiles shown). VLC's explicit qt-privacy-ask=0 was
#   observed; other audited preference lines were defaults/comments. No whole-file
#   VLC ownership proposed. Gedit dconf settings were not decoded; manual follow-up.
# - GTK files are KDE-generated; select a single owner in Phase 12 rather than
#   having Plasma GTK synchronization and HM repeatedly overwrite each other.
# - Removed weather notification state, file histories, last screenshot, generated
#   Plasma update markers and version/hash metadata. No browser profiles or
#   application databases were read. No Home Manager evaluation/build/runtime test.
# Validation: nix-instantiate --parse and --eval --strict --json of this module
# applied to {} passed (plain data evaluation only, NOT HM option validation).
# Independently compared evaluated output against live source: 478 KConfig values,
# 243 active shortcut actions and 22 static files matched exactly. Secret-pattern
# scan and git diff --check passed. Absence of a pattern is not universal proof;
# the primary safeguard was the explicit source allowlist and manual review.
{ ... }:
{
  home.username = "tachi";
  home.homeDirectory = "/home/tachi";

  programs.plasma = {
    enable = true;
    # Do not reset settings that were outside the audited selection.
    overrideConfig = false;
    shortcuts = {
      ActivityManager.switch-to-activity-b25f0152-88ba-452a-b461-9af4240167c6 = [ ];
      "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+K";
      kaccess."Toggle Screen Reader On and Off" = "Meta+Alt+S";
      kmix.decrease_microphone_volume = "Microphone Volume Down";
      kmix.decrease_volume = "Volume Down";
      kmix.decrease_volume_small = "Shift+Volume Down";
      kmix.increase_microphone_volume = "Microphone Volume Up";
      kmix.increase_volume = "Volume Up";
      kmix.increase_volume_small = "Shift+Volume Up";
      kmix.mic_mute = ["Microphone Mute" "Meta+Volume Mute"];
      kmix.mute = "Volume Mute";
      ksmserver."Halt Without Confirmation" = [ ];
      ksmserver."Lock Session" = ["Meta+L" "Screensaver"];
      ksmserver."Log Out" = "Ctrl+Alt+Del";
      ksmserver."Log Out Without Confirmation" = [ ];
      ksmserver.LogOut = [ ];
      ksmserver.Reboot = [ ];
      ksmserver."Reboot Without Confirmation" = [ ];
      ksmserver."Shut Down" = [ ];
      kwin."Activate Window Demanding Attention" = "Meta+Ctrl+A";
      kwin."Cycle Overview" = [ ];
      kwin."Cycle Overview Opposite" = [ ];
      kwin."Decrease Opacity" = [ ];
      kwin."Edit Tiles" = "Meta+T";
      kwin.Expose = ["Meta+F9" "Ctrl+F9"];
      kwin.ExposeAll = ["Meta+F10" "Launch (C)" "Ctrl+F10"];
      kwin.ExposeClass = ["Meta+F7" "Ctrl+F7"];
      kwin.ExposeClassCurrentDesktop = [ ];
      kwin."Grid View" = "Meta+G";
      kwin."Increase Opacity" = [ ];
      kwin."Kill Window" = "Meta+Ctrl+Esc";
      kwin."Move Tablet to Next LogicalOutput" = [ ];
      kwin.MoveMouseToCenter = "Meta+F6";
      kwin.MoveMouseToFocus = "Meta+F5";
      kwin.MoveZoomDown = [ ];
      kwin.MoveZoomLeft = [ ];
      kwin.MoveZoomRight = [ ];
      kwin.MoveZoomUp = [ ];
      kwin.Overview = "Meta+W";
      kwin."Setup Window Shortcut" = [ ];
      kwin."Show Desktop" = "Meta+D";
      kwin."Switch One Desktop Down" = "Meta+Ctrl+Down";
      kwin."Switch One Desktop Up" = "Meta+Ctrl+Up";
      kwin."Switch One Desktop to the Left" = "Meta+Ctrl+Left";
      kwin."Switch One Desktop to the Right" = "Meta+Ctrl+Right";
      kwin."Switch Window Down" = "Meta+Alt+Down";
      kwin."Switch Window Left" = "Meta+Alt+Left";
      kwin."Switch Window Right" = "Meta+Alt+Right";
      kwin."Switch Window Up" = "Meta+Alt+Up";
      kwin."Switch to Desktop 1" = "Ctrl+F1";
      kwin."Switch to Desktop 10" = [ ];
      kwin."Switch to Desktop 11" = [ ];
      kwin."Switch to Desktop 12" = [ ];
      kwin."Switch to Desktop 13" = [ ];
      kwin."Switch to Desktop 14" = [ ];
      kwin."Switch to Desktop 15" = [ ];
      kwin."Switch to Desktop 16" = [ ];
      kwin."Switch to Desktop 17" = [ ];
      kwin."Switch to Desktop 18" = [ ];
      kwin."Switch to Desktop 19" = [ ];
      kwin."Switch to Desktop 2" = "Meta+F2";
      kwin."Switch to Desktop 20" = [ ];
      kwin."Switch to Desktop 21" = [ ];
      kwin."Switch to Desktop 22" = [ ];
      kwin."Switch to Desktop 23" = [ ];
      kwin."Switch to Desktop 24" = [ ];
      kwin."Switch to Desktop 25" = [ ];
      kwin."Switch to Desktop 3" = "Meta+F3";
      kwin."Switch to Desktop 4" = "Meta+F4";
      kwin."Switch to Desktop 5" = [ ];
      kwin."Switch to Desktop 6" = [ ];
      kwin."Switch to Desktop 7" = [ ];
      kwin."Switch to Desktop 8" = [ ];
      kwin."Switch to Desktop 9" = [ ];
      kwin."Switch to Next Desktop" = [ ];
      kwin."Switch to Next Screen" = [ ];
      kwin."Switch to Previous Desktop" = [ ];
      kwin."Switch to Previous Screen" = [ ];
      kwin."Switch to Screen 0" = [ ];
      kwin."Switch to Screen 1" = [ ];
      kwin."Switch to Screen 2" = [ ];
      kwin."Switch to Screen 3" = [ ];
      kwin."Switch to Screen 4" = [ ];
      kwin."Switch to Screen 5" = [ ];
      kwin."Switch to Screen 6" = [ ];
      kwin."Switch to Screen 7" = [ ];
      kwin."Switch to Screen Above" = [ ];
      kwin."Switch to Screen Below" = [ ];
      kwin."Switch to Screen to the Left" = [ ];
      kwin."Switch to Screen to the Right" = [ ];
      kwin."Toggle Night Color" = [ ];
      kwin."Toggle Window Raise/Lower" = [ ];
      kwin."Walk Through Windows" = ["Meta+Tab" "Alt+Tab"];
      kwin."Walk Through Windows (Reverse)" = ["Meta+Shift+Tab" "Alt+Shift+Tab"];
      kwin."Walk Through Windows Alternative" = [ ];
      kwin."Walk Through Windows Alternative (Reverse)" = [ ];
      kwin."Walk Through Windows of Current Application" = ["Meta+`" "Alt+`"];
      kwin."Walk Through Windows of Current Application (Reverse)" = ["Meta+~" "Alt+~"];
      kwin."Walk Through Windows of Current Application Alternative" = [ ];
      kwin."Walk Through Windows of Current Application Alternative (Reverse)" = [ ];
      kwin."Window Above Other Windows" = [ ];
      kwin."Window Below Other Windows" = [ ];
      kwin."Window Close" = "Alt+F4";
      kwin."Window Custom Quick Tile Bottom" = [ ];
      kwin."Window Custom Quick Tile Left" = [ ];
      kwin."Window Custom Quick Tile Right" = [ ];
      kwin."Window Custom Quick Tile Top" = [ ];
      kwin."Window Fullscreen" = [ ];
      kwin."Window Grow Horizontal" = [ ];
      kwin."Window Grow Vertical" = [ ];
      kwin."Window Lower" = [ ];
      kwin."Window Maximize" = "Meta+PgUp";
      kwin."Window Maximize Horizontal" = [ ];
      kwin."Window Maximize Vertical" = [ ];
      kwin."Window Minimize" = "Meta+PgDown";
      kwin."Window Move" = [ ];
      kwin."Window Move Center" = [ ];
      kwin."Window No Border" = [ ];
      kwin."Window On All Desktops" = [ ];
      kwin."Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
      kwin."Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
      kwin."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
      kwin."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
      kwin."Window One Screen Down" = [ ];
      kwin."Window One Screen Up" = [ ];
      kwin."Window One Screen to the Left" = [ ];
      kwin."Window One Screen to the Right" = [ ];
      kwin."Window Operations Menu" = "Alt+F3";
      kwin."Window Pack Down" = [ ];
      kwin."Window Pack Left" = [ ];
      kwin."Window Pack Right" = [ ];
      kwin."Window Pack Up" = [ ];
      kwin."Window Quick Tile Bottom" = "Meta+Down";
      kwin."Window Quick Tile Bottom Left" = [ ];
      kwin."Window Quick Tile Bottom Right" = [ ];
      kwin."Window Quick Tile Left" = "Meta+Left";
      kwin."Window Quick Tile Right" = "Meta+Right";
      kwin."Window Quick Tile Top" = "Meta+Up";
      kwin."Window Quick Tile Top Left" = [ ];
      kwin."Window Quick Tile Top Right" = [ ];
      kwin."Window Raise" = [ ];
      kwin."Window Resize" = [ ];
      kwin."Window Shrink Horizontal" = [ ];
      kwin."Window Shrink Vertical" = [ ];
      kwin."Window to Desktop 1" = [ ];
      kwin."Window to Desktop 10" = [ ];
      kwin."Window to Desktop 11" = [ ];
      kwin."Window to Desktop 12" = [ ];
      kwin."Window to Desktop 13" = [ ];
      kwin."Window to Desktop 14" = [ ];
      kwin."Window to Desktop 15" = [ ];
      kwin."Window to Desktop 16" = [ ];
      kwin."Window to Desktop 17" = [ ];
      kwin."Window to Desktop 18" = [ ];
      kwin."Window to Desktop 19" = [ ];
      kwin."Window to Desktop 2" = [ ];
      kwin."Window to Desktop 20" = [ ];
      kwin."Window to Desktop 21" = [ ];
      kwin."Window to Desktop 22" = [ ];
      kwin."Window to Desktop 23" = [ ];
      kwin."Window to Desktop 24" = [ ];
      kwin."Window to Desktop 25" = [ ];
      kwin."Window to Desktop 3" = [ ];
      kwin."Window to Desktop 4" = [ ];
      kwin."Window to Desktop 5" = [ ];
      kwin."Window to Desktop 6" = [ ];
      kwin."Window to Desktop 7" = [ ];
      kwin."Window to Desktop 8" = [ ];
      kwin."Window to Desktop 9" = [ ];
      kwin."Window to Next Desktop" = [ ];
      kwin."Window to Next Screen" = "Meta+Shift+Right";
      kwin."Window to Previous Desktop" = [ ];
      kwin."Window to Previous Screen" = "Meta+Shift+Left";
      kwin."Window to Screen 0" = [ ];
      kwin."Window to Screen 1" = [ ];
      kwin."Window to Screen 2" = [ ];
      kwin."Window to Screen 3" = [ ];
      kwin."Window to Screen 4" = [ ];
      kwin."Window to Screen 5" = [ ];
      kwin."Window to Screen 6" = [ ];
      kwin."Window to Screen 7" = [ ];
      kwin.disableInputCapture = "Meta+Shift+Esc";
      kwin.view_actual_size = "Meta+0";
      kwin.view_zoom_in = ["Meta++" "Meta+="];
      kwin.view_zoom_out = "Meta+-";
      mediacontrol.mediavolumedown = [ ];
      mediacontrol.mediavolumeup = [ ];
      mediacontrol.nextmedia = "Media Next";
      mediacontrol.pausemedia = "Media Pause";
      mediacontrol.playmedia = [ ];
      mediacontrol.playpausemedia = "Media Play";
      mediacontrol.previousmedia = "Media Previous";
      mediacontrol.seekbackwardmedia = "Media Rewind";
      mediacontrol.seekbackwardmedialong = [ ];
      mediacontrol.seekforwardmedia = "Media Fast Forward";
      mediacontrol.seekforwardmedialong = [ ];
      mediacontrol.stopmedia = "Media Stop";
      org_kde_powerdevil."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
      org_kde_powerdevil."Decrease Screen Brightness" = "Monitor Brightness Down";
      org_kde_powerdevil."Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
      org_kde_powerdevil.Hibernate = "Hibernate";
      org_kde_powerdevil."Increase Keyboard Brightness" = "Keyboard Brightness Up";
      org_kde_powerdevil."Increase Screen Brightness" = "Monitor Brightness Up";
      org_kde_powerdevil."Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
      org_kde_powerdevil.PowerDown = "Power Down";
      org_kde_powerdevil.PowerOff = "Power Off";
      org_kde_powerdevil.Sleep = "Sleep";
      org_kde_powerdevil."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
      org_kde_powerdevil."Turn Off Screen" = [ ];
      org_kde_powerdevil.powerProfile = ["Battery" "Meta+B"];
      plasmashell."Slideshow Wallpaper Next Image" = [ ];
      plasmashell."activate application launcher" = ["Meta" "Alt+F1"];
      plasmashell."activate task manager entry 1" = "Meta+1";
      plasmashell."activate task manager entry 10" = [ ];
      plasmashell."activate task manager entry 2" = "Meta+2";
      plasmashell."activate task manager entry 3" = "Meta+3";
      plasmashell."activate task manager entry 4" = "Meta+4";
      plasmashell."activate task manager entry 5" = "Meta+5";
      plasmashell."activate task manager entry 6" = "Meta+6";
      plasmashell."activate task manager entry 7" = "Meta+7";
      plasmashell."activate task manager entry 8" = "Meta+8";
      plasmashell."activate task manager entry 9" = "Meta+9";
      plasmashell.clear-history = [ ];
      plasmashell.clipboard_action = "Meta+Ctrl+X";
      plasmashell.cycle-panels = "Meta+Alt+P";
      plasmashell.cycleNextAction = [ ];
      plasmashell.cyclePrevAction = [ ];
      plasmashell.edit_clipboard = [ ];
      plasmashell."manage activities" = "Meta+Q";
      plasmashell."next activity" = "Meta+A";
      plasmashell."previous activity" = "Meta+Shift+A";
      plasmashell.repeat_action = [ ];
      plasmashell."show dashboard" = "Ctrl+F12";
      plasmashell.show-barcode = [ ];
      plasmashell.show-on-mouse-pos = "Meta+V";
      plasmashell."switch to next activity" = [ ];
      plasmashell."switch to previous activity" = [ ];
      plasmashell."toggle do not disturb" = [ ];
      "services/org.kde.plasma-systemmonitor.desktop"._launch = ["Ctrl+Shift+Esc" "Meta+Esc"];
      "services/org.kde.spectacle.desktop".CurrentMonitorScreenShot = "Print";
      "services/org.kde.spectacle.desktop".OpenWithoutScreenshot = [ ];
      "services/org.kde.spectacle.desktop"._launch = "Meta+Shift+S";
    };
    configFile = {
      # Observed ~/.config/kdeglobals; state exclusions documented above.
      "kdeglobals"."ColorEffects:Disabled"."ChangeSelectionColor" = "";
      "kdeglobals"."ColorEffects:Disabled"."Color" = "56,56,56";
      "kdeglobals"."ColorEffects:Disabled"."ColorAmount" = "0";
      "kdeglobals"."ColorEffects:Disabled"."ColorEffect" = "0";
      "kdeglobals"."ColorEffects:Disabled"."ContrastAmount" = "0.65";
      "kdeglobals"."ColorEffects:Disabled"."ContrastEffect" = "1";
      "kdeglobals"."ColorEffects:Disabled"."Enable" = "";
      "kdeglobals"."ColorEffects:Disabled"."IntensityAmount" = "0.1";
      "kdeglobals"."ColorEffects:Disabled"."IntensityEffect" = "2";
      "kdeglobals"."ColorEffects:Inactive"."ChangeSelectionColor" = "true";
      "kdeglobals"."ColorEffects:Inactive"."Color" = "112,111,110";
      "kdeglobals"."ColorEffects:Inactive"."ColorAmount" = "0.025";
      "kdeglobals"."ColorEffects:Inactive"."ColorEffect" = "2";
      "kdeglobals"."ColorEffects:Inactive"."ContrastAmount" = "0.1";
      "kdeglobals"."ColorEffects:Inactive"."ContrastEffect" = "2";
      "kdeglobals"."ColorEffects:Inactive"."Enable" = "false";
      "kdeglobals"."ColorEffects:Inactive"."IntensityAmount" = "0";
      "kdeglobals"."ColorEffects:Inactive"."IntensityEffect" = "0";
      "kdeglobals"."Colors:Button"."BackgroundAlternate" = "30,87,116";
      "kdeglobals"."Colors:Button"."BackgroundNormal" = "41,44,48";
      "kdeglobals"."Colors:Button"."DecorationFocus" = "61,174,233";
      "kdeglobals"."Colors:Button"."DecorationHover" = "61,174,233";
      "kdeglobals"."Colors:Button"."ForegroundActive" = "61,174,233";
      "kdeglobals"."Colors:Button"."ForegroundInactive" = "161,169,177";
      "kdeglobals"."Colors:Button"."ForegroundLink" = "29,153,243";
      "kdeglobals"."Colors:Button"."ForegroundNegative" = "218,68,83";
      "kdeglobals"."Colors:Button"."ForegroundNeutral" = "246,116,0";
      "kdeglobals"."Colors:Button"."ForegroundNormal" = "252,252,252";
      "kdeglobals"."Colors:Button"."ForegroundPositive" = "39,174,96";
      "kdeglobals"."Colors:Button"."ForegroundVisited" = "155,89,182";
      "kdeglobals"."Colors:Complementary"."BackgroundAlternate" = "30,87,116";
      "kdeglobals"."Colors:Complementary"."BackgroundNormal" = "32,35,38";
      "kdeglobals"."Colors:Complementary"."DecorationFocus" = "61,174,233";
      "kdeglobals"."Colors:Complementary"."DecorationHover" = "61,174,233";
      "kdeglobals"."Colors:Complementary"."ForegroundActive" = "61,174,233";
      "kdeglobals"."Colors:Complementary"."ForegroundInactive" = "161,169,177";
      "kdeglobals"."Colors:Complementary"."ForegroundLink" = "29,153,243";
      "kdeglobals"."Colors:Complementary"."ForegroundNegative" = "218,68,83";
      "kdeglobals"."Colors:Complementary"."ForegroundNeutral" = "246,116,0";
      "kdeglobals"."Colors:Complementary"."ForegroundNormal" = "252,252,252";
      "kdeglobals"."Colors:Complementary"."ForegroundPositive" = "39,174,96";
      "kdeglobals"."Colors:Complementary"."ForegroundVisited" = "155,89,182";
      "kdeglobals"."Colors:Header"."BackgroundAlternate" = "32,35,38";
      "kdeglobals"."Colors:Header"."BackgroundNormal" = "41,44,48";
      "kdeglobals"."Colors:Header"."DecorationFocus" = "61,174,233";
      "kdeglobals"."Colors:Header"."DecorationHover" = "61,174,233";
      "kdeglobals"."Colors:Header"."ForegroundActive" = "61,174,233";
      "kdeglobals"."Colors:Header"."ForegroundInactive" = "161,169,177";
      "kdeglobals"."Colors:Header"."ForegroundLink" = "29,153,243";
      "kdeglobals"."Colors:Header"."ForegroundNegative" = "218,68,83";
      "kdeglobals"."Colors:Header"."ForegroundNeutral" = "246,116,0";
      "kdeglobals"."Colors:Header"."ForegroundNormal" = "252,252,252";
      "kdeglobals"."Colors:Header"."ForegroundPositive" = "39,174,96";
      "kdeglobals"."Colors:Header"."ForegroundVisited" = "155,89,182";
      "kdeglobals"."Colors:Header/Inactive"."BackgroundAlternate" = "41,44,48";
      "kdeglobals"."Colors:Header/Inactive"."BackgroundNormal" = "32,35,38";
      "kdeglobals"."Colors:Header/Inactive"."DecorationFocus" = "61,174,233";
      "kdeglobals"."Colors:Header/Inactive"."DecorationHover" = "61,174,233";
      "kdeglobals"."Colors:Header/Inactive"."ForegroundActive" = "61,174,233";
      "kdeglobals"."Colors:Header/Inactive"."ForegroundInactive" = "161,169,177";
      "kdeglobals"."Colors:Header/Inactive"."ForegroundLink" = "29,153,243";
      "kdeglobals"."Colors:Header/Inactive"."ForegroundNegative" = "218,68,83";
      "kdeglobals"."Colors:Header/Inactive"."ForegroundNeutral" = "246,116,0";
      "kdeglobals"."Colors:Header/Inactive"."ForegroundNormal" = "252,252,252";
      "kdeglobals"."Colors:Header/Inactive"."ForegroundPositive" = "39,174,96";
      "kdeglobals"."Colors:Header/Inactive"."ForegroundVisited" = "155,89,182";
      "kdeglobals"."Colors:Selection"."BackgroundAlternate" = "30,87,116";
      "kdeglobals"."Colors:Selection"."BackgroundNormal" = "61,174,233";
      "kdeglobals"."Colors:Selection"."DecorationFocus" = "61,174,233";
      "kdeglobals"."Colors:Selection"."DecorationHover" = "61,174,233";
      "kdeglobals"."Colors:Selection"."ForegroundActive" = "252,252,252";
      "kdeglobals"."Colors:Selection"."ForegroundInactive" = "161,169,177";
      "kdeglobals"."Colors:Selection"."ForegroundLink" = "253,188,75";
      "kdeglobals"."Colors:Selection"."ForegroundNegative" = "176,55,69";
      "kdeglobals"."Colors:Selection"."ForegroundNeutral" = "198,92,0";
      "kdeglobals"."Colors:Selection"."ForegroundNormal" = "252,252,252";
      "kdeglobals"."Colors:Selection"."ForegroundPositive" = "23,104,57";
      "kdeglobals"."Colors:Selection"."ForegroundVisited" = "155,89,182";
      "kdeglobals"."Colors:Tooltip"."BackgroundAlternate" = "32,35,38";
      "kdeglobals"."Colors:Tooltip"."BackgroundNormal" = "41,44,48";
      "kdeglobals"."Colors:Tooltip"."DecorationFocus" = "61,174,233";
      "kdeglobals"."Colors:Tooltip"."DecorationHover" = "61,174,233";
      "kdeglobals"."Colors:Tooltip"."ForegroundActive" = "61,174,233";
      "kdeglobals"."Colors:Tooltip"."ForegroundInactive" = "161,169,177";
      "kdeglobals"."Colors:Tooltip"."ForegroundLink" = "29,153,243";
      "kdeglobals"."Colors:Tooltip"."ForegroundNegative" = "218,68,83";
      "kdeglobals"."Colors:Tooltip"."ForegroundNeutral" = "246,116,0";
      "kdeglobals"."Colors:Tooltip"."ForegroundNormal" = "252,252,252";
      "kdeglobals"."Colors:Tooltip"."ForegroundPositive" = "39,174,96";
      "kdeglobals"."Colors:Tooltip"."ForegroundVisited" = "155,89,182";
      "kdeglobals"."Colors:View"."BackgroundAlternate" = "29,31,34";
      "kdeglobals"."Colors:View"."BackgroundNormal" = "20,22,24";
      "kdeglobals"."Colors:View"."DecorationFocus" = "61,174,233";
      "kdeglobals"."Colors:View"."DecorationHover" = "61,174,233";
      "kdeglobals"."Colors:View"."ForegroundActive" = "61,174,233";
      "kdeglobals"."Colors:View"."ForegroundInactive" = "161,169,177";
      "kdeglobals"."Colors:View"."ForegroundLink" = "29,153,243";
      "kdeglobals"."Colors:View"."ForegroundNegative" = "218,68,83";
      "kdeglobals"."Colors:View"."ForegroundNeutral" = "246,116,0";
      "kdeglobals"."Colors:View"."ForegroundNormal" = "252,252,252";
      "kdeglobals"."Colors:View"."ForegroundPositive" = "39,174,96";
      "kdeglobals"."Colors:View"."ForegroundVisited" = "155,89,182";
      "kdeglobals"."Colors:Window"."BackgroundAlternate" = "41,44,48";
      "kdeglobals"."Colors:Window"."BackgroundNormal" = "32,35,38";
      "kdeglobals"."Colors:Window"."DecorationFocus" = "61,174,233";
      "kdeglobals"."Colors:Window"."DecorationHover" = "61,174,233";
      "kdeglobals"."Colors:Window"."ForegroundActive" = "61,174,233";
      "kdeglobals"."Colors:Window"."ForegroundInactive" = "161,169,177";
      "kdeglobals"."Colors:Window"."ForegroundLink" = "29,153,243";
      "kdeglobals"."Colors:Window"."ForegroundNegative" = "218,68,83";
      "kdeglobals"."Colors:Window"."ForegroundNeutral" = "246,116,0";
      "kdeglobals"."Colors:Window"."ForegroundNormal" = "252,252,252";
      "kdeglobals"."Colors:Window"."ForegroundPositive" = "39,174,96";
      "kdeglobals"."Colors:Window"."ForegroundVisited" = "155,89,182";
      "kdeglobals"."General"."UseSystemBell" = "true";
      "kdeglobals"."KDE"."LookAndFeelPackage" = "org.kde.breezedark.desktop";
      "kdeglobals"."KDE"."contrast" = "4";
      "kdeglobals"."KDE"."frameContrast" = "0.2";
      "kdeglobals"."KFileDialog Settings"."Allow Expansion" = "false";
      "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = "true";
      "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = "true";
      "kdeglobals"."KFileDialog Settings"."Decoration position" = "2";
      "kdeglobals"."KFileDialog Settings"."Show Full Path" = "false";
      "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = "true";
      "kdeglobals"."KFileDialog Settings"."Show Preview" = "false";
      "kdeglobals"."KFileDialog Settings"."Show Speedbar" = "true";
      "kdeglobals"."KFileDialog Settings"."Show hidden files" = "false";
      "kdeglobals"."KFileDialog Settings"."Sort by" = "Name";
      "kdeglobals"."KFileDialog Settings"."Sort directories first" = "true";
      "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = "false";
      "kdeglobals"."KFileDialog Settings"."Sort reversed" = "false";
      "kdeglobals"."KFileDialog Settings"."Speedbar Width" = "170";
      "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";
      "kdeglobals"."WM"."activeBackground" = "39,44,49";
      "kdeglobals"."WM"."activeBlend" = "252,252,252";
      "kdeglobals"."WM"."activeForeground" = "252,252,252";
      "kdeglobals"."WM"."inactiveBackground" = "32,36,40";
      "kdeglobals"."WM"."inactiveBlend" = "161,169,177";
      "kdeglobals"."WM"."inactiveForeground" = "161,169,177";
      # Observed ~/.config/kwinrc; state exclusions documented above.
      "kwinrc"."Desktops"."Id_1" = "09b2ec0d-52a6-4d95-bcbb-e26df779049a";
      "kwinrc"."Desktops"."Number" = "1";
      "kwinrc"."Desktops"."Rows" = "1";
      "kwinrc"."Effect-zoom"."MouseTracking" = "4";
      "kwinrc"."Plugins"."zoomEnabled" = "false";
      "kwinrc"."Tiling/09b2ec0d-52a6-4d95-bcbb-e26df779049a/7406ccdd-bad6-4f9c-a3f7-e89075a74467"."padding" = "4";
      "kwinrc"."Tiling/09b2ec0d-52a6-4d95-bcbb-e26df779049a/7406ccdd-bad6-4f9c-a3f7-e89075a74467"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/09b2ec0d-52a6-4d95-bcbb-e26df779049a/d986ad97-97c2-47ec-b7b0-5f986cf56ef9"."padding" = "4";
      "kwinrc"."Tiling/09b2ec0d-52a6-4d95-bcbb-e26df779049a/d986ad97-97c2-47ec-b7b0-5f986cf56ef9"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Xwayland"."Scale" = "1";
      # Observed ~/.config/kcminputrc; state exclusions documented above.
      "kcminputrc"."Libinput/1267/12433/ELAN0504:01 04F3:3091 Touchpad"."DisableWhileTyping" = "false";
      "kcminputrc"."Libinput/1267/12433/ELAN0504:01 04F3:3091 Touchpad"."Enabled" = "true";
      # Observed ~/.config/kscreenlockerrc; state exclusions documented above.
      "kscreenlockerrc"."Daemon"."Autolock" = "false";
      "kscreenlockerrc"."Daemon"."LockOnResume" = "false";
      "kscreenlockerrc"."Daemon"."Timeout" = "0";
      # Observed ~/.config/powerdevilrc; state exclusions documented above.
      "powerdevilrc"."AC/Display"."DimDisplayIdleTimeoutSec" = "-1";
      "powerdevilrc"."AC/Display"."DimDisplayWhenIdle" = "false";
      "powerdevilrc"."AC/Display"."TurnOffDisplayIdleTimeoutSec" = "-1";
      "powerdevilrc"."AC/Display"."TurnOffDisplayWhenIdle" = "false";
      "powerdevilrc"."AC/SuspendAndShutdown"."AutoSuspendAction" = "0";
      "powerdevilrc"."AC/SuspendAndShutdown"."PowerButtonAction" = "0";
      "powerdevilrc"."Battery/SuspendAndShutdown"."AutoSuspendAction" = "0";
      "powerdevilrc"."Battery/SuspendAndShutdown"."PowerButtonAction" = "0";
      "powerdevilrc"."LowBattery/SuspendAndShutdown"."AutoSuspendIdleTimeoutSec" = "900";
      "powerdevilrc"."LowBattery/SuspendAndShutdown"."PowerButtonAction" = "0";
      # Observed ~/.config/kiorc; state exclusions documented above.
      "kiorc"."Confirmations"."ConfirmDelete" = "true";
      # Observed ~/.config/plasma-org.kde.plasma.desktop-appletsrc; state exclusions documented above.
      "plasma-org.kde.plasma.desktop-appletsrc"."ActionPlugins/0"."RightButton;NoModifier" = "org.kde.contextmenu";
      "plasma-org.kde.plasma.desktop-appletsrc"."ActionPlugins/1"."RightButton;NoModifier" = "org.kde.contextmenu";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1"."ItemGeometries-1536x864" = "Applet-30:416,16,336,256,0;Applet-27:752,16,256,256,0;Applet-24:1008,16,256,256,0;Applet-23:1264,16,256,256,0;Applet-31:416,272,336,272,0;Applet-28:752,272,256,272,0;Applet-29:1008,272,256,272,0;Applet-26:1264,272,256,272,0;";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1"."ItemGeometries-1920x1080" = "Applet-30:0,0,336,256,0;Applet-29:0,256,336,256,0;Applet-23:1664,0,256,256,0;Applet-24:0,512,336,256,0;Applet-26:1664,256,256,256,0;Applet-27:1664,512,256,256,0;Applet-31:0,768,336,224,0;Applet-28:1664,768,256,240,0;";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1"."ItemGeometriesHorizontal" = "Applet-30:0,0,336,256,0;Applet-29:0,256,336,256,0;Applet-23:1664,0,256,256,0;Applet-24:0,512,336,256,0;Applet-26:1664,256,256,256,0;Applet-27:1664,512,256,256,0;Applet-31:0,768,336,224,0;Applet-28:1664,768,256,240,0;";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1"."activityId" = "b25f0152-88ba-452a-b461-9af4240167c6";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1"."formfactor" = "0";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1"."lastScreen" = "0";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1"."location" = "0";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1"."plugin" = "org.kde.plasma.folder";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1"."wallpaperplugin" = "de.unkn0wn.htmlwallpaper";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23"."plugin" = "org.kde.plasma.systemmonitor.cpu";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration"."CurrentPreset" = "org.kde.plasma.systemmonitor";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/Appearance"."chartFace" = "org.kde.ksysguard.piechart";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/Appearance"."title" = "Celkové využitie CPU";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorColors"."cpu/all/usage" = "61,174,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorColors"."cpu/cpu0/usage" = "63,61,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorColors"."cpu/cpu1/usage" = "177,61,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorColors"."cpu/cpu2/usage" = "233,61,174";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorColors"."cpu/cpu3/usage" = "233,63,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorColors"."cpu/cpu4/usage" = "233,177,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorColors"."cpu/cpu5/usage" = "174,233,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorColors"."cpu/cpu6/usage" = "61,233,63";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorColors"."cpu/cpu7/usage" = "61,233,177";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorColors"."cpu/cpu\\\\d+/usage" = "188,233,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/SensorLabels"."cpu/cpu\\\\d+/usage" = "Celkové Využitie";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/Sensors"."highPrioritySensorIds" = "[\"cpu/cpu0/usage\",\"cpu/cpu1/usage\",\"cpu/cpu2/usage\",\"cpu/cpu3/usage\",\"cpu/cpu4/usage\",\"cpu/cpu5/usage\",\"cpu/cpu6/usage\",\"cpu/cpu7/usage\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/Sensors"."lowPrioritySensorIds" = "[\"cpu/all/cpuCount\",\"cpu/all/coreCount\",\"cpu/all/usage\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/Sensors"."totalSensors" = "[\"cpu/all/usage\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/23/Configuration/org.kde.ksysguard.piechart/General"."showLegend" = "false";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/24"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/24"."plugin" = "org.kde.plasma.systemmonitor.memory";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/24/Configuration"."CurrentPreset" = "org.kde.plasma.systemmonitor";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/24/Configuration/Appearance"."chartFace" = "org.kde.ksysguard.linechart";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/24/Configuration/Appearance"."title" = "Využitie pamäte";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/24/Configuration/SensorColors"."memory/physical/used" = "61,174,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/24/Configuration/Sensors"."highPrioritySensorIds" = "[\"memory/physical/used\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/24/Configuration/Sensors"."lowPrioritySensorIds" = "[\"memory/physical/total\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/24/Configuration/Sensors"."totalSensors" = "[\"memory/physical/usedPercent\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26"."plugin" = "org.kde.plasma.systemmonitor.cpu";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration"."CurrentPreset" = "org.kde.plasma.systemmonitor";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/Appearance"."chartFace" = "org.kde.ksysguard.linechart";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/Appearance"."title" = "Teplota CPU";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/all/averageTemperature" = "61,78,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/all/usage" = "61,174,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/cpu0/temperature" = "61,174,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/cpu1/temperature" = "77,61,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/cpu2/temperature" = "206,61,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/cpu3/temperature" = "233,61,131";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/cpu4/temperature" = "233,120,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/cpu5/temperature" = "217,233,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/cpu6/temperature" = "88,233,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/cpu7/temperature" = "61,233,163";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/SensorColors"."cpu/cpu\\\\d+/temperature" = "105,233,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/Sensors"."highPrioritySensorIds" = "[\"cpu/all/averageTemperature\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/Sensors"."lowPrioritySensorIds" = "[]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/26/Configuration/Sensors"."totalSensors" = "[\"cpu/all/usage\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27"."plugin" = "org.kde.plasma.systemmonitor.cpu";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration"."CurrentPreset" = "org.kde.plasma.systemmonitor";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/Appearance"."chartFace" = "org.kde.ksysguard.piechart";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/Appearance"."title" = "Celkové využitie GPU";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/SensorColors"."cpu/all/usage" = "61,174,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/SensorColors"."gpu/gpu0/name" = "61,233,195";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/SensorColors"."gpu/gpu0/usage" = "197,233,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/SensorColors"."gpu/gpu1/usage" = "61,233,135";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/SensorLabels"."gpu/gpu0/usage" = "Nvidia GPU";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/SensorLabels"."gpu/gpu1/usage" = "Intel GPU";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/Sensors"."highPrioritySensorIds" = "[\"gpu/gpu1/usage\",\"gpu/gpu0/usage\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/Sensors"."lowPrioritySensorIds" = "[]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/27/Configuration/Sensors"."totalSensors" = "[]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28"."plugin" = "org.kde.plasma.systemmonitor.cpu";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration"."CurrentPreset" = "org.kde.plasma.systemmonitor";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/Appearance"."chartFace" = "org.kde.ksysguard.linechart";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/Appearance"."title" = "Teploty GPU";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/SensorColors"."cpu/all/usage" = "61,174,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/SensorColors"."gpu/gpu0/temperature" = "62,233,0";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/SensorColors"."gpu/gpu1/temperature" = "72,61,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/SensorLabels"."gpu/gpu0/temperature" = "Nvidia GPU";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/SensorLabels"."gpu/gpu1/temperature" = "Intel GPU";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/Sensors"."highPrioritySensorIds" = "[\"gpu/gpu1/temperature\",\"gpu/gpu0/temperature\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/Sensors"."lowPrioritySensorIds" = "[]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/Sensors"."totalSensors" = "[\"cpu/all/usage\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/28/Configuration/org.kde.ksysguard.piechart/General"."showLegend" = "false";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/29"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/29"."plugin" = "org.kde.plasma.systemmonitor.diskactivity";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/29/Configuration"."CurrentPreset" = "org.kde.plasma.systemmonitor";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/29/Configuration/Appearance"."chartFace" = "org.kde.ksysguard.linechart";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/29/Configuration/Appearance"."title" = "Aktivita pevného disku";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/29/Configuration/SensorColors"."disk/all/read" = "233,120,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/29/Configuration/SensorColors"."disk/all/write" = "61,174,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/29/Configuration/Sensors"."highPrioritySensorIds" = "[\"disk/all/write\",\"disk/all/read\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30"."plugin" = "org.kde.plasma.systemmonitor.diskactivity";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration"."CurrentPreset" = "org.kde.plasma.systemmonitor";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration/Appearance"."chartFace" = "org.kde.ksysguard.linechart";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration/Appearance"."title" = "Aktivita Sieťe";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration/SensorColors"."disk/all/read" = "233,120,61";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration/SensorColors"."disk/all/write" = "61,174,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration/SensorColors"."network/all/download" = "233,61,115";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration/SensorColors"."network/all/upload" = "61,230,233";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration/SensorColors"."network/wlp0s20f3/download" = "61,233,178";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration/SensorColors"."network/wlp0s20f3/downloadBits" = "233,61,123";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration/SensorColors"."network/wlp0s20f3/upload" = "233,61,76";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/30/Configuration/Sensors"."highPrioritySensorIds" = "[\"network/all/download\",\"network/all/upload\"]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/31"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/31"."plugin" = "org.kde.plasma.volume";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Applets/31/Configuration/General"."migrated" = "true";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Wallpaper/de.unkn0wn.htmlwallpaper/General"."DisplayPage" = "file:///home/tachi/bckg/index.html";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Wallpaper/de.unkn0wn.htmlwallpaper/General"."InsecureHTTPS" = "true";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Wallpaper/org.kde.image/General"."Image" = "file:///home/tachi/Obrázky/Snímky obrazovky/Snímka obrazovky_20260725_230033.png";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2"."activityId" = "";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2"."formfactor" = "2";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2"."lastScreen" = "0";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2"."location" = "4";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2"."plugin" = "org.kde.panel";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2"."wallpaperplugin" = "org.kde.image";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/18"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/18"."plugin" = "org.kde.plasma.digitalclock";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/18/Configuration"."popupHeight" = "451";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/18/Configuration"."popupWidth" = "560";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/18/Configuration/Appearance"."fontWeight" = "400";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/19"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/19"."plugin" = "org.kde.plasma.showdesktop";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/3"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/3"."plugin" = "org.kde.plasma.kickoff";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/3/Configuration"."popupHeight" = "535";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/3/Configuration"."popupWidth" = "633";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33"."plugin" = "org.kde.plasma.advanced-weather-widget";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration"."popupHeight" = "751";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration"."popupWidth" = "800";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."altitude" = "429";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."countryCode" = "SK";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."latitude" = "48.7276";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."librewxrArrows" = "true";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."librewxrLayer" = "both";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."librewxrTheme" = "light";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."locationName" = "Handlová, Trenčín Region, Slovakia";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."longitude" = "18.76012";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."radarZoom" = "7";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."roundValues" = "false";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."savedLocations" = "[{\"name\":\"Handlová, Trenčín Region, Slovakia\",\"lat\":48.7276,\"lon\":18.76012,\"altitude\":424,\"timezone\":\"Europe/Bratislava\",\"countryCode\":\"SK\",\"starred\":true}]";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."simpleFontAutoSz" = "25";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."simpleIconAutoSz" = "54";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."simplePanelDim" = "38";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."simplePanelLargeDim" = "54";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/33/Configuration/General"."timezone" = "Europe/Bratislava";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/4"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/4"."plugin" = "org.kde.plasma.pager";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/5"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/5"."plugin" = "org.kde.plasma.icontasks";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/6"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/6"."plugin" = "org.kde.plasma.marginsseparator";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7"."activityId" = "";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7"."formfactor" = "0";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7"."lastScreen" = "-1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7"."location" = "0";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7"."plugin" = "org.kde.plasma.systemtray";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7"."popupHeight" = "444";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7"."popupWidth" = "444";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7"."wallpaperplugin" = "org.kde.image";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/10"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/10"."plugin" = "org.kde.plasma.clipboard";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/11"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/11"."plugin" = "org.kde.plasma.cameraindicator";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/12"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/12"."plugin" = "org.kde.plasma.devicenotifier";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/13"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/13"."plugin" = "org.kde.plasma.volume";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/13/Configuration/General"."migrated" = "true";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/14"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/14"."plugin" = "org.kde.kscreen";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/15"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/15"."plugin" = "org.kde.plasma.keyboardlayout";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/16"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/16"."plugin" = "org.kde.plasma.weather";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/16/Configuration/Appearance"."showHumidityInTooltip" = "false";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/16/Configuration/Appearance"."showTemperatureInTooltip" = "false";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/16/Configuration/Appearance"."showWindInTooltip" = "false";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/16/Configuration/WeatherStation"."placeDisplayName" = "Banská Bystrica, Slovakia, SK";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/16/Configuration/WeatherStation"."placeInfo" = "Banská Bystrica, Slovakia, SK|3061186";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/16/Configuration/WeatherStation"."provider" = "bbcukmet";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/17"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/17"."plugin" = "org.kde.plasma.keyboardindicator";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/20"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/20"."plugin" = "org.kde.plasma.networkmanagement";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/21"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/21"."plugin" = "org.kde.plasma.bluetooth";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/22"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/22"."plugin" = "org.kde.plasma.battery";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/25"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/25"."plugin" = "org.kde.plasma.brightness";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/32"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/32"."plugin" = "org.kde.plasma.mediacontroller";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/8"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/8"."plugin" = "org.kde.plasma.manage-inputmethod";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/9"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/Applets/9"."plugin" = "org.kde.plasma.notifications";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/General"."extraItems" = "org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.plasma.mediacontroller,org.kde.plasma.clipboard,org.kde.plasma.cameraindicator,org.kde.plasma.devicenotifier,org.kde.plasma.volume,org.kde.plasma.bluetooth,org.kde.plasma.battery,org.kde.kscreen,org.kde.plasma.brightness,org.kde.plasma.keyboardlayout,org.kde.plasma.weather,org.kde.plasma.keyboardindicator,org.kde.plasma.networkmanagement";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/Applets/7/General"."knownItems" = "org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.plasma.mediacontroller,org.kde.plasma.clipboard,org.kde.plasma.cameraindicator,org.kde.plasma.devicenotifier,org.kde.plasma.volume,org.kde.plasma.bluetooth,org.kde.plasma.battery,org.kde.kscreen,org.kde.plasma.brightness,org.kde.plasma.keyboardlayout,org.kde.plasma.weather,org.kde.plasma.keyboardindicator,org.kde.plasma.networkmanagement";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/2/General"."AppletOrder" = "3;33;5;4;6;7;18;19";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/32"."activityId" = "b25f0152-88ba-452a-b461-9af4240167c6";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/32"."formfactor" = "0";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/32"."immutability" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/32"."lastScreen" = "1";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/32"."location" = "0";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/32"."plugin" = "org.kde.plasma.folder";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/32"."wallpaperplugin" = "org.kde.image";
      # Observed ~/.config/plasmashellrc; state exclusions documented above.
      "plasmashellrc"."PlasmaViews/Panel 2"."floating" = "1";
      "plasmashellrc"."PlasmaViews/Panel 2"."panelLengthMode" = "0";
      "plasmashellrc"."PlasmaViews/Panel 2"."panelOpacity" = "2";
      "plasmashellrc"."PlasmaViews/Panel 2"."panelVisibility" = "0";
      "plasmashellrc"."PlasmaViews/Panel 2/Defaults"."thickness" = "46";
      # Observed ~/.config/dolphinrc; state exclusions documented above.
      "dolphinrc"."IconsMode"."PreviewSize" = "160";
      "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = "false";
      "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = "22";
      "dolphinrc"."MainWindow"."MenuBar" = "Disabled";
      # Observed ~/.config/katerc; state exclusions documented above.
      "katerc"."General"."Days Meta Infos" = "30";
      "katerc"."General"."PinnedDocuments" = "";
      "katerc"."General"."Save Meta Infos" = "true";
      "katerc"."General"."Show Full Path in Title" = "false";
      "katerc"."General"."Show Menu Bar" = "true";
      "katerc"."General"."Show Status Bar" = "true";
      "katerc"."General"."Show Tab Bar" = "true";
      "katerc"."General"."Show Url Nav Bar" = "true";
      "katerc"."KTextEditor View"."Allow Mark Menu" = "true";
      "katerc"."KTextEditor View"."Auto Brackets" = "true";
      "katerc"."KTextEditor View"."Auto Center Lines" = "0";
      "katerc"."KTextEditor View"."Auto Completion" = "true";
      "katerc"."KTextEditor View"."Auto Completion Preselect First Entry" = "true";
      "katerc"."KTextEditor View"."Backspace Remove Composed Characters" = "false";
      "katerc"."KTextEditor View"."Bookmark Menu Sorting" = "0";
      "katerc"."KTextEditor View"."Bracket Match Preview" = "false";
      "katerc"."KTextEditor View"."Chars To Enclose Selection" = "<>(){}[]'\"";
      "katerc"."KTextEditor View"."Cycle Through Bookmarks" = "true";
      "katerc"."KTextEditor View"."Default Mark Type" = "1";
      "katerc"."KTextEditor View"."Disable bracket match highlight if inactive" = "false";
      "katerc"."KTextEditor View"."Disable current line highlight if inactive" = "false";
      "katerc"."KTextEditor View"."Dynamic Word Wrap" = "true";
      "katerc"."KTextEditor View"."Dynamic Word Wrap Align Indent" = "80";
      "katerc"."KTextEditor View"."Dynamic Word Wrap At Static Marker" = "false";
      "katerc"."KTextEditor View"."Dynamic Word Wrap Indicators" = "1";
      "katerc"."KTextEditor View"."Dynamic Wrap not at word boundaries" = "false";
      "katerc"."KTextEditor View"."Enable Accessibility" = "true";
      "katerc"."KTextEditor View"."Enable Tab completion" = "false";
      "katerc"."KTextEditor View"."Enter To Insert Completion" = "true";
      "katerc"."KTextEditor View"."Fold First Line" = "false";
      "katerc"."KTextEditor View"."Folding Bar" = "true";
      "katerc"."KTextEditor View"."Folding Preview" = "true";
      "katerc"."KTextEditor View"."Hide cursor if inactive" = "false";
      "katerc"."KTextEditor View"."Icon Bar" = "false";
      "katerc"."KTextEditor View"."Input Mode" = "0";
      "katerc"."KTextEditor View"."Keyword Completion" = "true";
      "katerc"."KTextEditor View"."Line Modification" = "true";
      "katerc"."KTextEditor View"."Line Numbers" = "true";
      "katerc"."KTextEditor View"."Max Clipboard History Entries" = "20";
      "katerc"."KTextEditor View"."Maximum Search History Size" = "100";
      "katerc"."KTextEditor View"."Mouse Paste At Cursor Position" = "false";
      "katerc"."KTextEditor View"."Multiple Cursor Modifier" = "134217728";
      "katerc"."KTextEditor View"."Persistent Selection" = "false";
      "katerc"."KTextEditor View"."Scroll Bar Marks" = "false";
      "katerc"."KTextEditor View"."Scroll Bar Mini Map All" = "true";
      "katerc"."KTextEditor View"."Scroll Bar Mini Map Width" = "60";
      "katerc"."KTextEditor View"."Scroll Bar MiniMap" = "true";
      "katerc"."KTextEditor View"."Scroll Bar Preview" = "true";
      "katerc"."KTextEditor View"."Scroll Past End" = "false";
      "katerc"."KTextEditor View"."Search/Replace Flags" = "140";
      "katerc"."KTextEditor View"."Shoe Line Ending Type in Statusbar" = "false";
      "katerc"."KTextEditor View"."Show Documentation With Completion" = "true";
      "katerc"."KTextEditor View"."Show File Encoding" = "true";
      "katerc"."KTextEditor View"."Show Folding Icons On Hover Only" = "true";
      "katerc"."KTextEditor View"."Show Line Count" = "false";
      "katerc"."KTextEditor View"."Show Scrollbars" = "0";
      "katerc"."KTextEditor View"."Show Statusbar Dictionary" = "true";
      "katerc"."KTextEditor View"."Show Statusbar Highlighting Mode" = "true";
      "katerc"."KTextEditor View"."Show Statusbar Input Mode" = "true";
      "katerc"."KTextEditor View"."Show Statusbar Line Column" = "true";
      "katerc"."KTextEditor View"."Show Statusbar Tab Settings" = "true";
      "katerc"."KTextEditor View"."Show Word Count" = "false";
      "katerc"."KTextEditor View"."Smart Copy Cut" = "true";
      "katerc"."KTextEditor View"."Statusbar Line Column Compact Mode" = "true";
      "katerc"."KTextEditor View"."Text Drag And Drop" = "true";
      "katerc"."KTextEditor View"."User Sets Of Chars To Enclose Selection" = "";
      "katerc"."KTextEditor View"."Vi Input Mode Steal Keys" = "false";
      "katerc"."KTextEditor View"."Vi Relative Line Numbers" = "false";
      "katerc"."KTextEditor View"."Word Completion" = "true";
      "katerc"."KTextEditor View"."Word Completion Minimal Word Length" = "3";
      "katerc"."KTextEditor View"."Word Completion Remove Tail" = "true";
      "katerc"."MainWindow"."1920x1080 screen: Window-Maximized" = "true";
      "katerc"."filetree"."editShade" = "30,78,103";
      "katerc"."filetree"."listMode" = "false";
      "katerc"."filetree"."middleClickToClose" = "false";
      "katerc"."filetree"."shadingEnabled" = "true";
      "katerc"."filetree"."showCloseButton" = "false";
      "katerc"."filetree"."showFullPathOnRoots" = "false";
      "katerc"."filetree"."showToolbar" = "true";
      "katerc"."filetree"."sortRole" = "0";
      "katerc"."filetree"."viewShade" = "77,46,91";
      # Observed ~/.config/spectaclerc; state exclusions documented above.
      "spectaclerc"."General"."clipboardGroup" = "PostScreenshotCopyImage";
      "spectaclerc"."ImageSave"."translatedScreenshotsFolder" = "Snímky obrazovky";
      "spectaclerc"."VideoSave"."translatedScreencastsFolder" = "Nahrávky obrazovky";
      "spectaclerc"."ViewerWindow"."1920x1080 screen: Height" = "570";
      "spectaclerc"."ViewerWindow"."1920x1080 screen: Width" = "975";
      # Observed ~/.config/arkrc; state exclusions documented above.
      "arkrc"."General"."LockSidebar" = "true";
      "arkrc"."General"."ShowSidebar" = "true";
      "arkrc"."MainWindow"."StatusBar" = "Disabled";
    };
  };

  # Static files preserve serialization and avoid enabling duplicate system packages.
  # .zshrc intentionally retains the observed compinit and fastfetch invocation.
  # Git identity is public configuration; the two safe.directory entries are observed.
  # No SSH/Home Manager Git/Zsh defaults or new MIME associations are added.
  home.file = {
    ".zshrc".text = "# Lines configured by zsh-newuser-install\nHISTFILE=~/.histfile\nHISTSIZE=1000\nSAVEHIST=1000\nbindkey -e\n# End of lines configured by zsh-newuser-install\n# The following lines were added by compinstall\nzstyle :compinstall filename '/home/tachi/.zshrc'\n\nautoload -Uz compinit\ncompinit\n# End of lines added by compinstall\n\nfastfetch\n";
    ".gitconfig".text = "[safe]\n\tdirectory = /etc/nixos\n\tdirectory = /home/tachi/nixos\n[user]\n\tname = Agrael11\n\temail = oliver.neuschl@gmail.com\n";
    ".config/mimeapps.list".text = "[Added Associations]\napplication/octet-stream=code.desktop;\nx-scheme-handler/cfauth=CurseForge.desktop;\nx-scheme-handler/curseforge=curseforge.desktop;CurseForge.desktop;\nx-scheme-handler/webcal=brave-browser.desktop\n\n[Default Applications]\napplication/octet-stream=code.desktop;\nx-scheme-handler/cfauth=CurseForge.desktop\nx-scheme-handler/curseforge=curseforge.desktop\nx-scheme-handler/webcal=brave-browser.desktop\n";
    ".config/MangoHud/MangoHud.conf".text = "fps_limit=60+120+0\ntoggle_fps_limit=Shift_L+F1\ntoggle_hud=Shift_L+F10\n\nhorizontal\ntable_columns=4\nfont_size=12\n\ntime\ntime_format=%d.%m.%Y %H:%M\ncpu_stats\ncpu_temp\ncpu_mhz\ngpu_stats\ngpu_temp\ngpu_core_clock\nram\nprocmem\nvram\nfps\nframe_timing\n";
    ".config/gtk-3.0/settings.ini".text = "[Settings]\ngtk-application-prefer-dark-theme=true\ngtk-button-images=true\ngtk-cursor-blink=true\ngtk-cursor-blink-time=1000\ngtk-cursor-theme-name=breeze_cursors\ngtk-cursor-theme-size=24\ngtk-decoration-layout=icon:minimize,maximize,close\ngtk-enable-animations=true\ngtk-font-name=Noto Sans,  10\ngtk-icon-theme-name=breeze-dark\ngtk-menu-images=true\ngtk-modules=colorreload-gtk-module\ngtk-primary-button-warps-slider=true\ngtk-sound-theme-name=ocean\ngtk-theme-name=\ngtk-toolbar-style=3\ngtk-xft-dpi=98304\n";
    ".config/gtk-4.0/settings.ini".text = "[Settings]\ngtk-application-prefer-dark-theme=true\ngtk-cursor-blink=true\ngtk-cursor-blink-time=1000\ngtk-cursor-theme-name=breeze_cursors\ngtk-cursor-theme-size=24\ngtk-decoration-layout=icon:minimize,maximize,close\ngtk-enable-animations=true\ngtk-font-name=Noto Sans,  10\ngtk-icon-theme-name=breeze-dark\ngtk-primary-button-warps-slider=true\ngtk-sound-theme-name=ocean\ngtk-theme-name=\ngtk-xft-dpi=98304\n";
    ".config/autostart/steam.desktop".text = "[Desktop Entry]\nActions=Store;Community;Library;Servers;Screenshots;News;Settings;BigPicture;Friends;\nCategories=Network;FileTransfer;Game;\nComment[sk_SK]=Application for managing and playing games on Steam\nComment=Application for managing and playing games on Steam\nExec=steam -pipewire\nGenericName[sk_SK]=\nGenericName=\nIcon=steam\nMimeType=\nName[sk_SK]=Steam\nName=Steam\nPath=\nPrefersNonDefaultGPU=true\nStartupNotify=true\nTerminal=false\nTerminalOptions=\nType=Application\nX-KDE-RunOnDiscreteGpu=true\nX-KDE-SubstituteUID=false\nX-KDE-Username=\n\n[Desktop Action BigPicture]\nExec=steam steam://open/bigpicture\nName=Big Picture\n\n[Desktop Action Community]\nExec=steam steam://url/CommunityHome/\nName=Community\n\n[Desktop Action Friends]\nExec=steam steam://open/friends\nName=Friends\n\n[Desktop Action Library]\nExec=steam steam://open/games\nName=Library\n\n[Desktop Action News]\nExec=steam steam://openurl/https://store.steampowered.com/news\nName=News\n\n[Desktop Action Screenshots]\nExec=steam steam://open/screenshots\nName=Screenshots\n\n[Desktop Action Servers]\nExec=steam steam://open/servers\nName=Servers\n\n[Desktop Action Settings]\nExec=steam steam://open/settings\nName=Settings\n\n[Desktop Action Store]\nExec=steam steam://store\nName=Store\n";
    ".config/htop/htoprc".text = "# Beware! This file is rewritten by htop when settings are changed in the interface.\n# The parser is also very primitive, and not human-friendly.\nhtop_version=3.5.1\nconfig_reader_min_version=3\nfields=0 48 17 18 38 39 130 2 46 47 49 1\nhide_kernel_threads=1\nhide_userland_threads=0\nhide_running_in_container=0\nshadow_other_users=0\nshow_thread_names=0\nshow_program_path=1\nhighlight_base_name=0\nhighlight_deleted_exe=1\nshadow_distribution_path_prefix=0\nhighlight_megabytes=1\nhighlight_threads=1\nhighlight_changes=0\nhighlight_changes_delay_secs=5\nfind_comm_in_cmdline=1\nstrip_exe_from_cmdline=1\nshow_merged_command=0\nheader_margin=1\nscreen_tabs=1\ndetailed_cpu_time=0\ncpu_count_from_one=0\nshow_cpu_smt_labels=0\nshow_cpu_usage=1\nshow_cpu_frequency=0\nshow_cpu_temperature=0\ndegree_fahrenheit=0\nshow_cached_memory=1\nupdate_process_names=0\naccount_guest_in_cpu_meter=0\ncolor_scheme=0\nenable_mouse=1\ndelay=15\nhide_function_bar=0\nheader_layout=two_50_50\ncolumn_meters_0=LeftCPUs Memory Swap\ncolumn_meter_modes_0=1 1 1\ncolumn_meters_1=RightCPUs Tasks LoadAverage Uptime\ncolumn_meter_modes_1=1 2 2 2\ntree_view=0\nsort_key=46\ntree_sort_key=0\nsort_direction=-1\ntree_sort_direction=1\ntree_view_always_by_pid=0\nall_branches_collapsed=0\nscreen:Main=PID USER PRIORITY NICE M_VIRT M_RESIDENT M_PRIV STATE PERCENT_CPU PERCENT_MEM TIME Command\n.sort_key=PERCENT_CPU\n.tree_sort_key=PID\n.tree_view_always_by_pid=0\n.tree_view=0\n.sort_direction=-1\n.tree_sort_direction=1\n.all_branches_collapsed=0\nscreen:I/O=PID USER IO_PRIORITY IO_RATE IO_READ_RATE IO_WRITE_RATE PERCENT_SWAP_DELAY PERCENT_IO_DELAY Command\n.sort_key=IO_RATE\n.tree_sort_key=PID\n.tree_view_always_by_pid=0\n.tree_view=0\n.sort_direction=-1\n.tree_sort_direction=1\n.all_branches_collapsed=0\n";
    ".config/user-dirs.dirs".text = "# This file is written by xdg-user-dirs-update\n# If you want to change or add directories, just edit the line you're\n# interested in. All local changes will be retained on the next run.\n# Format is XDG_xxx_DIR=\"$HOME/yyy\", where yyy is a shell-escaped\n# homedir-relative path, or XDG_xxx_DIR=\"/yyy\", where /yyy is an\n# absolute path. No other format is supported.\n# \nXDG_DESKTOP_DIR=\"$HOME/Desktop\"\nXDG_DOWNLOAD_DIR=\"$HOME/Stiahnuté\"\nXDG_TEMPLATES_DIR=\"$HOME/Šablóny\"\nXDG_PUBLICSHARE_DIR=\"$HOME/Verejné\"\nXDG_DOCUMENTS_DIR=\"$HOME/Dokumenty\"\nXDG_MUSIC_DIR=\"$HOME/Hudba\"\nXDG_PICTURES_DIR=\"$HOME/Obrázky\"\nXDG_VIDEOS_DIR=\"$HOME/Video\"\nXDG_PROJECTS_DIR=\"$HOME/Projekty\"\n";
    ".config/user-dirs.locale".text = "sk_SK";
    ".config/Code/User/settings.json".text = "{\n    \"git.enableSmartCommit\": true\n}";
    ".gtkrc-2.0".text = "gtk-enable-animations=1\ngtk-theme-name=\"\"\ngtk-primary-button-warps-slider=1\ngtk-toolbar-style=3\ngtk-menu-images=1\ngtk-button-images=1\ngtk-cursor-blink-time=1000\ngtk-cursor-blink=1\ngtk-cursor-theme-size=24\ngtk-cursor-theme-name=\"breeze_cursors\"\ngtk-sound-theme-name=\"ocean\"\ngtk-icon-theme-name=\"breeze-dark\"\ngtk-font-name=\"Noto Sans,  10\"\n\n";
    ".config/konsolerc".text = "MenuBar=Disabled\n\n[General]\nConfigVersion=1\n\n[UiSettings]\nColorScheme=\n";
    ".config/JetBrains/CLion2026.2/options/colors.scheme.xml".text = "<application>\n  <component name=\"EditorColorsManagerImpl\">\n    <global_color_scheme name=\"Islands Dark\" />\n  </component>\n</application>";
    ".config/JetBrains/CLion2026.2/options/filetypes.xml".text = "<application>\n  <component name=\"FileTypeManager\" version=\"19\">\n    <extensionMap>\n      <mapping pattern=\"*.sarif*.json\" type=\"SARIF\" />\n      <mapping pattern=\"*.sarif.json\" type=\"SARIF\" />\n    </extensionMap>\n  </component>\n</application>";
    ".config/JetBrains/Rider2026.2/options/advancedSettings.xml".text = "<application>\n  <component name=\"AdvancedSettings\">\n    <option name=\"settings\">\n      <map>\n        <entry key=\"floating.codeToolbar.hide\" value=\"true\" />\n      </map>\n    </option>\n  </component>\n</application>";
    ".config/JetBrains/Rider2026.2/options/colors.scheme.xml".text = "<application>\n  <component name=\"EditorColorsManagerImpl\">\n    <global_color_scheme name=\"Rider Islands Dark\" />\n  </component>\n</application>";
    ".config/JetBrains/Rider2026.2/options/editor.codeinsight.xml".text = "<application>\n  <component name=\"RiderCodeCompletionExtraSettings\">\n    <option name=\"allowToCompleteWithWhitespace\" value=\"false\" />\n  </component>\n</application>";
    ".config/JetBrains/Rider2026.2/options/editor.xml".text = "<application>\n  <component name=\"CodeInsightSettings\">\n    <option name=\"completionCaseSensitive\" value=\"2\" />\n    <option name=\"selectAutopopupSuggestionsByChars\" value=\"true\" />\n    <option name=\"AUTO_POPUP_JAVADOC_INFO\" value=\"true\" />\n    <option name=\"COMPLETION_CASE_SENSITIVE\" value=\"2\" />\n    <option name=\"SELECT_AUTOPOPUP_SUGGESTIONS_BY_CHARS\" value=\"true\" />\n    <option name=\"AUTOCOMPLETE_ON_CODE_COMPLETION\" value=\"false\" />\n    <option name=\"INSERT_BRACE_ON_ENTER\" value=\"false\" />\n  </component>\n  <component name=\"CodeVisionSettings\">\n    <option name=\"defaultPosition\" value=\"Top\" />\n  </component>\n  <component name=\"EditorSettings\">\n    <option name=\"STRIP_TRAILING_SPACES\" value=\"None\" />\n    <option name=\"IS_WHEEL_FONTCHANGE_ENABLED\" value=\"true\" />\n    <option name=\"IS_WHEEL_FONTCHANGE_PERSISTENT\" value=\"true\" />\n  </component>\n  <component name=\"TodoConfiguration\">\n    <pattern pattern=\"\\bNotImplementedException\\b\" />\n    <pattern icon=\"default\" case-sensitive=\"true\" pattern=\"(?&lt;=\\W|^)(?&lt;TAG&gt;BUG:)(\\W|$)(.*)\" />\n    <pattern pattern=\"(?&lt;=\\W|^)(?&lt;TAG&gt;TODO)(\\W|$)(.*)\" />\n  </component>\n</application>";
    ".config/JetBrains/Rider2026.2/options/filetypes.xml".text = "<application>\n  <component name=\"FileTypeManager\" version=\"19\">\n    <ignoreFiles list=\"*.pyc;*.pyo;*.rbc;*.yarb;.DS_Store;.git;.hg;.mypy_cache;.pytest_cache;.ruff_cache;.svn;CVS;__pycache__;_svn;vssver.scc;vssver2.scc\" />\n    <extensionMap>\n      <removed_mapping ext=\"tps\" approved=\"true\" type=\"XML\" />\n      <removed_mapping ext=\"usf\" approved=\"true\" type=\"C/C++\" />\n      <removed_mapping ext=\"ush\" approved=\"true\" type=\"C/C++ Header\" />\n    </extensionMap>\n  </component>\n</application>";
    ".config/JetBrains/Rider2026.2/options/ui.lnf.xml".text = "<application>\n  <component name=\"UISettings\">\n    <option name=\"SHOW_PREVIEW_IN_SEARCH_EVERYWHERE\" value=\"true\" />\n  </component>\n</application>";
    ".config/JetBrains/RustRover2026.2/options/colors.scheme.xml".text = "<application>\n  <component name=\"EditorColorsManagerImpl\">\n    <global_color_scheme name=\"Islands Dark\" />\n  </component>\n</application>";
  };

  # Observed RetroArch subset; notes only, not a partial replacement file:
  # video_driver =  "vulkan"
  # video_vsync =  "true"
  # video_fullscreen =  "true"
  # video_windowed_fullscreen =  "true"
  # audio_driver =  "pulse"
  # audio_latency =  "64"
  # menu_driver =  "ozone"
  # gamemode_enable =  "true"
  # autosave_interval =  "10"
  # config_save_on_exit =  "true"
  # input_menu_toggle =  "f1"
  # input_exit_emulator =  "escape"
  # input_save_state =  "f2"
  # input_load_state =  "f4"
}

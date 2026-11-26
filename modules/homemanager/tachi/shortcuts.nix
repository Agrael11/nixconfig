{ pkgs, ... }:
let
  snap = pkgs.runCommand "tachi-snap-cycle" {} ''
    dest=$out/share/kwin/scripts/tachi-snap-cycle
    mkdir -p "$dest/contents/code"
    cp ${./snap-cycle.js} "$dest/contents/code/main.js"
    cp ${./snap-metadata.json} "$dest/metadata.json"
  '';
in {
  home.packages = [ snap ];
  programs.plasma = {
    configFile = {
      "kwinrc".Plugins.tachi-snap-cycleEnabled = true;
      "spectaclerc".General.clipboardGroup = "PostScreenshotCopyImage";
      "spectaclerc".ImageSave.translatedScreenshotsFolder = "Snímky obrazovky";
      "spectaclerc".VideoSave.translatedScreencastsFolder = "Nahrávky obrazovky";
    };
    shortcuts = {
      kwin = {
        "Window Maximize" = "Meta+Up";
        "Window Minimize" = "Meta+Down";
        "Window to Next Screen" = "Meta+Shift+Right";
        "Window to Previous Screen" = "Meta+Shift+Left";
        "Walk Through Windows" = "Alt+Tab";
        "Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
        "Window Quick Tile Left" = [];
        "Window Quick Tile Right" = [];
        "Window Quick Tile Top" = [];
        "Window Quick Tile Bottom" = [];
        "Tachi Snap Left" = "Meta+Left";
        "Tachi Snap Right" = "Meta+Right";
      };
      "services/io.missioncenter.MissionCenter.desktop"._launch = "Ctrl+Shift+Esc";
      "services/org.kde.plasma-systemmonitor.desktop"._launch = "Meta+Esc";
      "services/org.kde.spectacle.desktop" = {
        ActiveWindowScreenShot = "Alt+Print";
        CurrentMonitorScreenShot = "Print";
      };
    };
  };
}

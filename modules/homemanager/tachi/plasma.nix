{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.nixconfig;
  data = builtins.fromJSON (builtins.readFile ./layout-data.json);
  widgetLib = import "${inputs.plasma-manager}/modules/widgets/lib.nix" { inherit lib; };
  sensors = suffix: builtins.toJSON (map (gpu: "${gpu}/${suffix}") cfg.gpuSensors);
  # Captured from the Desktop Plasma containment after manually arranging the
  # eight widgets at the 1920x1080 logical resolution (200% display scaling).
  # Keep the shared layout-data.json positions unchanged for Laptop.
  desktopWidgetPositions = {
    network = { horizontal = 0; vertical = 0; };
    disk = { horizontal = 0; vertical = 240; };
    memory = { horizontal = 0; vertical = 480; };
    volume = { horizontal = 0; vertical = 720; };
    cpu = { horizontal = 1648; vertical = 0; };
    gpu-temperature = { horizontal = 1648; vertical = 240; };
    gpu = { horizontal = 1648; vertical = 480; };
    cpu-temperature = { horizontal = 1648; vertical = 720; };
  };
  adapt = w: let
    targetPosition = if cfg.host == "desktop"
      then desktopWidgetPositions.${w.role} else w.position;
  in {
    inherit (w) name size;
    # libplasma 6.6.6 treats (0, 0) as "no geometry hint" and centers the
    # widget, ignoring its size too. One pixel rounds to the same origin cell
    # while making the supported addWidget geometry hint unambiguous.
    position = targetPosition // lib.optionalAttrs
      (targetPosition.horizontal == 0 && targetPosition.vertical == 0) { horizontal = 1; };
    screen = cfg.monitorScreen;
    config = (lib.removeAttrs w.config [ "" ]) // w.config."" // {
      SensorLabels = lib.optionalAttrs (w.role == "gpu" || w.role == "gpu-temperature") (
        builtins.listToAttrs (lib.imap0 (i: gpu: {
          name = "${gpu}/${if w.role == "gpu" then "usage" else "temperature"}";
          value = if i == 0 then "NVIDIA GPU" else "Intel GPU";
        }) cfg.gpuSensors)
      );
      Sensors = if w.role == "gpu" then {
        highPrioritySensorIds = sensors "usage";
        lowPrioritySensorIds = "[]"; totalSensors = "[]";
      } else if w.role == "gpu-temperature" then {
        highPrioritySensorIds = sensors "temperature";
        lowPrioritySensorIds = "[]"; totalSensors = "[]";
      } else if w.role == "cpu" then {
        highPrioritySensorIds = builtins.toJSON [ "cpu/cpu\\d+/usage" ];
        lowPrioritySensorIds = builtins.toJSON [ "cpu/all/cpuCount" "cpu/all/coreCount" ];
        totalSensors = builtins.toJSON [ "cpu/all/usage" ];
      } else (w.config.Sensors or {});
    };
  };
  weather = pkgs.runCommand "advanced-weather-widget" {} ''
    dest=$out/share/plasma/plasmoids/org.kde.plasma.advanced-weather-widget
    mkdir -p "$dest"
    cp -r ${inputs.advanced-weather}/contents ${inputs.advanced-weather}/metadata.json "$dest/"
    cp ${inputs.advanced-weather}/LICENSE "$dest/"
  '';
  trayScript = pkgs.writeText "configure-tray-weather.js" ''
    ${builtins.readFile ./tray-weather.js}
    print("TACHI_WEATHER_UPDATED:" + configureTrayWeather(${builtins.toJSON data.trayWeather}));
  '';
in {
  home.packages = [ weather ];
  home.sessionVariables.QML2_IMPORT_PATH = lib.makeSearchPath "lib/qt-6/qml" [
    pkgs.qt6.qtlocation pkgs.qt6.qtpositioning pkgs.qt6.qtwebengine
  ];
  programs.plasma = {
    panels = [{
      screen = "all";
      location = "bottom"; height = 54; floating = true;
      lengthMode = "fit";
      opacity = "translucent";
      # Upstream's lastScreen[$i] write alone leaves both new panels on screen
      # zero in Plasma 6.6.6. Use the supported live containment setter too.
      extraSettings = ''
        panel.screen = screenID;
      '' + lib.optionalString (cfg.host == "desktop") ''
        if (screenID !== 0) panel.opacity = "adaptive";
        const preservedLaunchers = ${builtins.toJSON data.desktopLaunchers};
        panelWidgets["org.kde.plasma.icontasks"].currentConfigGroup = ["General"];
        panelWidgets["org.kde.plasma.icontasks"].writeConfig("launchers", preservedLaunchers[Math.min(screenID, preservedLaunchers.length - 1)]);
      '';
      # Plasma 6.6.6 PanelView::DodgeWindows is numeric mode 2.
      hiding = "dodgewindows";
      widgets = [
        "org.kde.plasma.kickoff"
        { name = "org.kde.plasma.advanced-weather-widget"; config.General = data.weather; }
        { name = "org.kde.plasma.icontasks"; config.General.showOnlyCurrentScreen = true; }
        "org.kde.plasma.pager" "org.kde.plasma.marginsseparator"
        "org.kde.plasma.systemtray"
        "org.kde.plasma.digitalclock" "org.kde.plasma.showdesktop"
      ];
    }];
    desktop.widgets = map adapt data.widgets;
    # Upstream deletes the entire applet file as a pre-command. Preserve the
    # desktop/wallpaper containment data; the script replaces panels only.
    startup.desktopScript.panels.preCommands = lib.mkForce "";
    startup.desktopScript.set_desktop_widgets.text = lib.mkForce ''
      let allDesktops = desktops();
      const managedTypes = ${builtins.toJSON (lib.unique (map (w: w.name) config.programs.plasma.desktop.widgets))};
      allDesktops.filter(d => d.screen === ${toString cfg.monitorScreen}).forEach(d => {
        d.widgets().filter(w => managedTypes.indexOf(w.type) !== -1).forEach(w => w.remove());
      });
      ${widgetLib.addDesktopWidgetStmts "desktopWidgets" config.programs.plasma.desktop.widgets}
    '';
    # items.configs currently has no effect in upstream's tray converter. Use
    # the supported ConfigFile API after the tray's async applet creation.
    startup.startupScript.tachi-tray-weather = {
      priority = 7;
      text = ''
        # Panel revision ${builtins.hashString "sha256" (builtins.toJSON config.programs.plasma.panels)}
        weather_ready=0
        for attempt in 1 2 3 4 5; do
          result=$(${pkgs.qt6.qttools}/bin/qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat ${trayScript})")
          case "$result" in *TACHI_WEATHER_UPDATED:[1-9]*) weather_ready=1; break;; esac
          sleep 2
        done
        if [ "$weather_ready" -eq 0 ]; then
          echo "Weather tray not ready; preferences will retry at next login." >&2
          false
        fi
      '';
    };
  };
}

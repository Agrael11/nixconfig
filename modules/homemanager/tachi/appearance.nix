{ ... }: {
  programs.plasma.configFile = {
    "kdeglobals"."KDE".widgetStyle = "Fusion";
    "kwinrc"."org.kde.kdecoration2".theme = "Vánok";
    # Konsole's menu visibility is a root KConfig entry, not a profile setting.
    "konsolerc"."".MenuBar = "Disabled";
  };
}

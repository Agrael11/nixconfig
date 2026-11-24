{ ... }: {
  nixconfig.mutable = map (entry: {
    kind = "ini"; path = ".config/autostart/${entry.name}.desktop";
    values."Desktop Entry" = {
      Type = "Application"; Name = entry.label; Exec = entry.exec; Icon = entry.name;
      Hidden = "false"; "X-GNOME-Autostart-enabled" = "true";
    };
  }) [ { name = "steam"; label = "Steam"; exec = "steam -pipewire"; }
    { name = "discord"; label = "Discord"; exec = "discord"; } ] ++ [
    { kind = "ini"; path = ".config/autostart/lunarclient.desktop";
      values."Desktop Entry" = { Type = "Application"; Hidden = "true"; "X-GNOME-Autostart-enabled" = "false"; }; }
  ];
}

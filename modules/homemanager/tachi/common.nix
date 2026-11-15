{ ... }: {
  imports = [
    ./plasma.nix ./appearance.nix ./shortcuts.nix ./power.nix
    ./locale-xdg.nix ./development.nix ./gaming.nix
    ./applications.nix ./autostart.nix ./wallpaper.nix ./migration.nix
    ./preserve-unset.nix
  ];
  home.username = "tachi";
  home.homeDirectory = "/home/tachi";
  # First HM compatibility baseline; unrelated to NixOS system.stateVersion.
  home.stateVersion = "26.05";
  xdg.enable = true;
  # System documentation/fonts remain NixOS-owned. No user font preferences
  # were approved, and the repository deliberately disables documentation.
  manual = { html.enable = false; json.enable = false; manpages.enable = false; };
  programs.man.enable = false;
  fonts.fontconfig.enable = false;
  programs.plasma = {
    enable = true;
    overrideConfig = false;
    immutableByDefault = false;
  };
}

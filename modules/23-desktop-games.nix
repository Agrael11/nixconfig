({ pkgs, ... }: {
  # Desktop entertainment and gaming packages.

  environment.systemPackages = with pkgs; [
    lutris
    gamemode
    protonup-qt
    mangohud
    gamescope
  ];
})

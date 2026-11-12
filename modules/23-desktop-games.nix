({ pkgs, ... }: {
  # Desktop entertainment and gaming packages.

  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraLibraries = pkgs: [ pkgs.file ];
    })
    gamemode
    protonup-qt
    mangohud
    gamescope
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      file
    ];
  };

  services.flatpak.packages = [
    "net.retrodeck.retrodeck"
  ];
})

{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kdePackages.qtwebengine
    wine
    winetricks
    xwayland
    appimage-run
  ];

  services.flatpak.packages = [ "com.usebottles.bottles" ];
}

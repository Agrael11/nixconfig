({ pkgs, ... }: {
  # Graphical utilities and GUI helper packages.

  environment.systemPackages = with pkgs; [
    gnome-disk-utility
    docker-compose
    kdePackages.qtwebengine
    gparted
    brave
    gedit
    wine
    winetricks
    filezilla
    xwayland
    appimage-run
    freerdp
    vlc
    discord
    qbittorrent
    kodi
    ffmpeg
    makemkv
    thunderbird
  ];


  services.flatpak.packages = [
    "com.usebottles.bottles"
  ];
})

({ pkgs, ... }: {
  # Desktop utilities and GUI helper packages.

  environment.systemPackages = with pkgs; [
    gnome-disk-utility
    fastfetch
    openrgbx
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
    bottles
  ];
})

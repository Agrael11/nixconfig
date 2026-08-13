({ pkgs, ... }: {
  # CLI-focused utilities for system administration and daily terminal work.

  environment.systemPackages = with pkgs; [
    pciutils
    memtest86-efi
    coreutils
    hwinfo
    mesa-demos
    nano
    wget
    curl
    sudo
    tree
    zip
    unzip
    mc
    git
    file
    zstd
    android-tools
    htop
    tmux
    binutils
    grub2
    ntfs3g
    v4l-utils
    mono
    msedit
    dotnet-sdk_10
    dotnet-runtime_10
    p7zip
<<<<<<< HEAD
    i2c-tools
=======
    cowsay
    killall
>>>>>>> 1ecc5de11142afbc8aa9841f6f48d276020cf070
  ];
})

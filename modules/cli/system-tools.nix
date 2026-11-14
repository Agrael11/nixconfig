{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    pciutils
    memtest86-efi
    coreutils
    hwinfo
    sudo
    file
    android-tools
    htop
    tmux
    binutils
    grub2
    v4l-utils
    killall
    i2c-tools
    fastfetch
  ];
}

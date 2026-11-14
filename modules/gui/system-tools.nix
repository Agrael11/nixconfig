{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnome-disk-utility
    gparted
  ];

  programs.partition-manager.enable = true;
}

{ pkgs, ... }: {
  services.hardware.openrgb.enable = true;
  services.udev.packages = [ pkgs.openrgb ];
  users.extraGroups.i2c.members = [ "tachi" ];
}

{ pkgs, ... }: {
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.host.addNetworkInterface = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.vhostUserPackages = with pkgs; [ virtiofsd ];

  users.extraGroups.vboxusers.members = [ "tachi" ];
}

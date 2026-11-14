{ ... }: {
  imports = [
    ./hardware-modules.nix
    ./common-modules.nix
    ./cli-modules.nix
    ./gui-modules.nix
  ];

  networking.hostName = "Desktop";
  system.stateVersion = "26.05";
}

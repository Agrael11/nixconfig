{ ... }: {
  imports = [
    ./hardware-modules.nix
    ./common-modules.nix
    ./cli-modules.nix
    ./gui-modules.nix
  ];

  networking.hostName = "Laptop";
  system.stateVersion = "26.05";
}

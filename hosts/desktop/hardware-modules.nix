{ inputs, ... }: {
  imports = [
    inputs.sc0710.nixosModules.default
    ./hardware-generated.nix
    ./hardware-manual.nix
    inputs.grub2-themes.nixosModules.default
  ];
}

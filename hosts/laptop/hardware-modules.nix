{ inputs, ... }: {
  imports = [
    ./hardware-generated.nix
    ./hardware-manual.nix
    inputs.grub2-themes.nixosModules.default
  ];
}

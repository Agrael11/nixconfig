{ inputs, ... }: {
  imports = [
    ../../modules/hardware/sc0710-fix.nix
    ./hardware-generated.nix
    ./hardware-manual.nix
    inputs.grub2-themes.nixosModules.default
  ];
}

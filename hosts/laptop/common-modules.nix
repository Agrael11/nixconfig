{ inputs, ... }: {
  imports = [
    ./remote-builds.nix
    ../../modules/common/nix.nix
    ../../modules/common/sudo.nix
    ../../modules/common/users.nix
    ../../modules/common/system.nix
    ../../modules/common/shell.nix
    ../../modules/common/audio.nix
    ../../modules/common/hardware-services.nix
    ../../modules/common/runtime-libraries.nix
    ../../modules/common/flatpak.nix
    ../../modules/common/firewall.nix
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];
}

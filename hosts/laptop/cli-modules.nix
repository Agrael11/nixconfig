{ ... }: {
  imports = [
    ../../modules/cli/system-tools.nix
    ../../modules/cli/graphics-diagnostics.nix
    ../../modules/cli/text-editors.nix
    ../../modules/cli/file-managers.nix
    ../../modules/cli/network-tools.nix
    ../../modules/cli/archives.nix
    ../../modules/cli/storage-tools.nix
    ../../modules/cli/games.nix
    ../../modules/cli/media.nix
    ../../modules/cli/browsers.nix
    ../../modules/cli/productivity.nix
    ../../modules/cli/nix-tools.nix
    ../../modules/cli/isotools.nix
    ../../modules/cli/services/ssh.nix
    ../../modules/cli/services/mdns.nix
    ../../modules/cli/services/samba.nix
    ../../modules/cli/services/containers.nix
    ../../modules/cli/services/virtualisation.nix
    ../../modules/cli/services/zerotier.nix
    ../../modules/cli/services/gamemode.nix
  ];
}

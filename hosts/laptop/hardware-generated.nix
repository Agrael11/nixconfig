# Detected hardware and physical-filesystem baseline from nixos-generate-config.
# Transient container and automount entries are excluded.
# Keep additional hardware policy in hardware-manual.nix.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d9807655-133d-44f3-b478-8bd8677ee098";
      fsType = "ext4";
    };

  fileSystems."/media/data_disk" =
    { device = "/dev/disk/by-uuid/417a46a4-b863-4b84-8399-4fb1aa770c3a";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2C26-57DF";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/da633cab-426d-4ef5-9479-2e1844b143c1"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

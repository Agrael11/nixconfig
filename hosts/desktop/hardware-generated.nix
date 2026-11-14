# Detected hardware and physical-filesystem baseline from nixos-generate-config.
# Transient container and automount entries are excluded.
# Keep additional hardware policy in hardware-manual.nix.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/f7d90429-9439-4053-91b3-e6b2193d4459";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D742-7346";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/media/tachi/DATA_NVME1" =
    { device = "/dev/disk/by-uuid/2EFA10AAFA106FF7";
      fsType = "ntfs3";
    };

  fileSystems."/media/tachi/DATA_NVME2" =
    { device = "/dev/disk/by-uuid/58DC1774DC174B9E";
      fsType = "ntfs3";
    };

  fileSystems."/media/tachi/DATA_SYSTEM" =
    { device = "/dev/disk/by-uuid/B2E2249DFD92233D";
      fsType = "ntfs3";
    };

  fileSystems."/media/mediadisk" =
    { device = "/dev/disk/by-uuid/4C58849358847E08";
      fsType = "ntfs3";
    };

  fileSystems."/media/romdisk" =
    { device = "/dev/disk/by-uuid/FAD696A1D6965E27";
      fsType = "ntfs3";
    };

  fileSystems."/media/tachi/DATA_MAIN" =
    { device = "/dev/disk/by-uuid/4A9AFCA69AFC9025";
      fsType = "ntfs3";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/2e9d52d8-5d02-43f1-b58f-27b5396ccc88"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

# Additional hardware settings and compatibility workarounds.
{ config, lib, pkgs, ... }: {

#  services.logind = {
#    enable = true;
#    settings = {
#      Login = {
#        HandlePowerKey = "suspend";
#        HandleSleepKey = "suspend";
#        PowerKeyIgnoreInhibited = "yes";
#        SuspendKeyIgnoreInhibited = "yes";
#        InhibitorsMax = 0;
#      };
#    };
#  };

  boot = {
    initrd.kernelModules = ["usbhid" "joydev" "xpad" "videodev" "uvcvideo" "cx23885" "i2c-dev" "i2c-piix4" "i2c-i801" "vfio" "vfio_pci" "vfio_iommu_type1"] ++ [ "ntsync" "sg" ];
    consoleLogLevel = 3;
    
    extraModulePackages = [ config.boot.kernelPackages.nvidiaPackages.legacy_580 ];
    
    loader.timeout = 0;
    
    loader.grub = {
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      default = "saved";
      configurationLimit = 3;
    };
    loader.grub2-theme = {
      enable = true;
      theme = "stylish";
      footer = true;
      splashImage = ../../assets/background-stylish.jpg;
      customResolution = "1920x1080";  # Optional: Set a custom resolution
    };
  };

  fileSystems."/media/retro-shares" = {
    fsType = "cifs";
    device = "//192.168.1.3/moviestuff_2/ROMS"; 
    options = let
    automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [
      "${automount_opts},credentials=/etc/nixos/secrets/retroshares,uid=1000,gid=1000,vers=3.0"
      "nofail"
    ];
  };

  fileSystems."/media/main-shares/F" = {
    fsType = "cifs";
    device = "//192.168.1.3/F/"; 
    options = let
    automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [
      "${automount_opts},credentials=/etc/nixos/secrets/mainshares,uid=1000,gid=1000,vers=3.0"
      "nofail"
    ];
  };

  fileSystems."/media/main-shares/moviestuff" = {
    fsType = "cifs";
    device = "//192.168.1.3/moviestuff/"; 
    options = let
    automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [
      "${automount_opts},credentials=/etc/nixos/secrets/mainshares,uid=1000,gid=1000,vers=3.0"
      "nofail"
    ];
  };

  fileSystems."/media/main-shares/moviestuff_2" = {
    fsType = "cifs";
    device = "//192.168.1.3/moviestuff_2/"; 
    options = let
    automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [
      "${automount_opts},credentials=/etc/nixos/secrets/mainshares,uid=1000,gid=1000,vers=3.0"
      "nofail"
    ];
  };

  fileSystems."/media/main-shares/PS2" = {
    fsType = "cifs";
    device = "//192.168.1.3/PS2/"; 
    options = let
    automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [
      "${automount_opts},credentials=/etc/nixos/secrets/mainshares,uid=1000,gid=1000,vers=3.0"
      "nofail"
    ];
  };

  fileSystems."/media/main-shares/Users" = {
    fsType = "cifs";
    device = "//192.168.1.3/Users/"; 
    options = let
    automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [
      "${automount_opts},credentials=/etc/nixos/secrets/mainshares,uid=1000,gid=1000,vers=3.0"
      "nofail"
    ];
  };

    services.udev.extraRules = ''
      KERNEL=="sr0", GROUP="optical", MODE="0660"
      KERNEL=="sg*", GROUP="optical", MODE="0660"
    '';

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f0u11u3.useDHCP = lib.mkDefault true;networking.networkmanager.enable = true;
  networking.networkmanager.enable = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  hardware.xone.enable = true;
  hardware.xpadneo.enable = true;
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=1
  '';
  boot.supportedFilesystems = [ "ntfs" ];
  nixpkgs.config.allowUnfree = true;

  hardware.enableAllFirmware = true;
  
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.python3 ];
    postPatch = ''
      python3 - <<'EOF'
      from pathlib import Path
      import re

      for p in Path("kernel").rglob("*.[ch]"):
          text = p.read_text(encoding="utf-8", errors="ignore")
          
          # Handle return strncpy with proper return pointer adjustment
          text = re.sub(
              r'return\s+\bstrncpy\s*\(([^,]+),\s*([^,]+),\s*([^)]+)\)\s*;',
              r'strscpy(\1, \2, \3);\n    return \1;',
              text
          )
          
          # Replace only exact strncpy function calls, sparing symbols like nvkms_strncpy
          text = re.sub(r'\bstrncpy\s*\(', 'strscpy(', text)
          
          p.write_text(text, encoding="utf-8")
      EOF
    '';
  });

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.nvidiaSettings = true; 

  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.i2c.enable = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.nvidia.open = false;
  
  hardware.nvidia = {
    powerManagement.enable = true;
    powerManagement.finegrained = false; # keep this off on Pascal
  };
  
  hardware.nvidia.prime = {
    sync.enable = true; # or offload mode
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "intel_iommu=on" "quiet" "nvidia-drm.fbdev=1" "simpledrm=0" "pci=realloc" "pci=assign-busses" ];
  # Retain the existing USB/optical initrd support in addition to the detected baseline.
  boot.initrd.availableKernelModules = [ "usbhid" "usb_storage" "sr_mod" ];

  environment.sessionVariables = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  boot.loader.grub.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;
  boot.plymouth.theme = "breeze";
  boot.loader.grub.memtest86.enable = true;
}

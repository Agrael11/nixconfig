# Additional hardware settings and compatibility workarounds.
{ config, lib, pkgs, pkgs-unstable, ... }: {

  services.logind = {
    enable = true;
    settings = {
      Login = {
        HandlePowerKey = "poweroff";
        HandleSleepKey = "suspend";
        PowerKeyIgnoreInhibited = "yes";
        SuspendKeyIgnoreInhibited = "yes";
        InhibitorsMax = 0;
      };
    };
  };

  boot = {
    initrd.kernelModules = ["usbhid" "joydev" "xpad" "videodev" "uvcvideo" "cx23885" "i2c-dev" "i2c-piix4" "i2c-i801" "vfio" "vfio_pci" "vfio_iommu_type1"] ++ [ "ntsync" "sg" ];

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
      splashImage = ../../assets/background-stylish2.jpg;
      customResolution = "3840x2160";  # Optional: Set a custom resolution
    };
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
  # networking.interfaces.wlp0s20f0u11u3.useDHCP = lib.mkDefault true;

  fileSystems."/media/romdisk".options = [ "uid=1000" "gid=100" "dmask=022" "fmask=133" ];

  fileSystems."/media/mediadisk".options = [ "uid=1000" "gid=100" "dmask=022" "fmask=133" ];

  fileSystems."/media/tachi/DATA_MAIN".options = [ "uid=1000" "gid=100" "dmask=022" "fmask=133" ];
  
  fileSystems."/media/tachi/DATA_SYSTEM".options = [ "uid=1000" "gid=100" "dmask=022" "fmask=133" ];

  fileSystems."/media/tachi/DATA_NVME1".options = [ "uid=1000" "gid=100" "dmask=022" "fmask=133" ];

  fileSystems."/media/tachi/DATA_NVME2".options = [ "uid=1000" "gid=100" "dmask=022" "fmask=133" ];

  hardware.xone.enable = true;
  hardware.xpadneo.enable = true;
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=1
  '';
  boot.supportedFilesystems = [ "ntfs" ];
  nixpkgs.config.allowUnfree = true;

  hardware.enableAllFirmware = true;

	hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.nvidiaSettings = true; 

  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # enable the kernel module and `sc0710-cli` script
  hardware.sc0710.enable = true;

  # enable automatic firmware updates with the systemd service
  # hardware.sc0710.enableFirmware = true;

  hardware.i2c.enable = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.nvidia.open = true;

  boot.kernelPackages = pkgs-unstable.linuxPackages_latest;
  boot.kernelParams = [ "intel_iommu=on" "quiet" "nvidia-drm.fbdev=1" "simpledrm=0" "pci=realloc" "pci=assign-busses" ];
  boot.kernelModules = [ "sc0710" "i2c-dev" "i2c-piix4" "i2c-i801" ];

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

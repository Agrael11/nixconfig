({pkgs, ...}: {
	system.stateVersion = "26.05";

	nix.settings = {
		substituters = [ "https://cache.nixos.org/" ];
		trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
		trusted-users = [ "root" "tachi" ];
		experimental-features = [ "nix-command" "flakes" ];
	};

	imports = [
		./modules/common/users.nix
		./modules/common/system.nix
		./modules/common/shell.nix
		./modules/common/audio.nix
		./modules/common/hardware-services.nix
		./modules/common/runtime-libraries.nix
		./modules/common/flatpak.nix
		./modules/common/firewall.nix
		./modules/cli/system-tools.nix
		./modules/cli/graphics-diagnostics.nix
		./modules/cli/text-editors.nix
		./modules/cli/file-managers.nix
		./modules/cli/network-tools.nix
		./modules/cli/archives.nix
		./modules/cli/storage-tools.nix
		./modules/cli/games.nix
		./modules/cli/media.nix
		./modules/cli/browsers.nix
		./modules/cli/productivity.nix
		./modules/cli/nix-tools.nix
		./modules/cli/isotools.nix
		./modules/cli/services/ssh.nix
		./modules/cli/services/samba.nix
		./modules/cli/services/containers.nix
		./modules/cli/services/virtualisation.nix
		./modules/cli/services/zerotier.nix
		./modules/cli/services/gamemode.nix
		./modules/overrides/retroarch.nix
		./modules/overrides/application-packages.nix
	];

	boot.loader.grub.enable = true;
	boot.kernelParams = [ "intel_iommu=on" "quiet" "nvidia-drm.fbdev=1" "simpledrm=0" "pci=realloc" "pci=assign-busses" ];
	boot.loader.efi.canTouchEfiVariables = true;
	boot.plymouth.enable = true;
	boot.plymouth.theme = "breeze";
	boot.loader.grub.memtest86.enable = true;
	boot.initrd.kernelModules = ["usbhid" "joydev" "xpad" "videodev" "uvcvideo" "cx23885" "i2c-dev" "i2c-piix4" "i2c-i801" "vfio" "vfio_pci" "vfio_iommu_type1"];

	security.sudo.extraConfig = ''
    	Defaults pwfeedback
    	Defaults timestamp_timeout=-1
  	'';

})

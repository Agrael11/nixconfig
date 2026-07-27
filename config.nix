({pkgs, ...}: {
	system.stateVersion = "26.05";

	nix.settings = {
		substituters = [ "https://cache.nixos.org/" ];
		trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
		trusted-users = [ "root" "tachi" ];
		experimental-features = [ "nix-command" "flakes" ];
	};

	imports = [
		./modules/10-users.nix
		./modules/20-cli-tools.nix
		./modules/21-desktop-tools.nix
		./modules/22-cli-games.nix
		./modules/23-desktop-games.nix
		./modules/23-retroarch-fix.nix
		./modules/24-cli-productivity.nix
		./modules/25-desktop-productivity.nix
		./modules/30-services.nix
		./modules/31-samba.nix
		./modules/32-firewall.nix
		./modules/41-sddm-astronaut-theme.nix
		./modules/60-overlays.nix
	];

	boot.loader.grub.enable = true;
	boot.kernelParams = [ "intel_iommu=on" "quiet" "nvidia-drm.fbdev=1" "simpledrm=0" "pci=realloc" "pci=assign-busses" ];
	boot.loader.efi.canTouchEfiVariables = true;
	boot.kernelPackages = pkgs.linuxPackages_latest;
	boot.plymouth.enable = true;
	boot.plymouth.theme = "breeze";
	boot.loader.grub.memtest86.enable = true;
	boot.initrd.kernelModules = ["usbhid" "joydev" "xpad" "videodev" "uvcvideo" "cx23885" "i2c-dev" "i2c-piix4" "i2c-i801" "vfio" "vfio_pci" "vfio_iommu_type1"];

	security.rtkit.enable = true;
	security.sudo.extraRules = [
		{
			users = [ "tachi" ];
			commands = [
				{
					command = "/root/grub-switcher.sh";
					options = [ "NOPASSWD" ];
				}	
			];
		}
	];

	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		jack.enable = true;
	};


	services.hardware.openrgb.enable = true;
	services.flatpak.enable = true;

	i18n.defaultLocale = "sk_SK.UTF-8";
	console.keyMap = "sk-qwertz";

	services.openssh.enable = true;



	programs.partition-manager.enable = true;

	
	programs.nh = {
		enable = true;
		clean.enable = true;
		clean.extraArgs = "--keep-since 4d --keep 3";
	};

	programs.noisetorch.enable = true;
  	time.timeZone = "Europe/Bratislava";
  	time.hardwareClockInLocalTime = true;

	programs.zsh = {
		enable = true;
		ohMyZsh = {
			enable = true;
			theme = "agnoster";
			plugins = ["git" "z"];
		};
	};

	documentation.enable = false;
})

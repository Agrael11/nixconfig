({pkgs, ...}: {
	system.stateVersion = "26.05";

	nix.settings = {
		substituters = [ "https://cache.nixos.org/" ];
		trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
		trusted-users = [ "root" "tachi" ];
	};

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

	environment.shells = [ pkgs.zsh ];

	security.sudo.enable = true;
	users.users.root = {
		initialPassword = "Nix";
		shell = pkgs.zsh;
	};
	users.users.tachi = {
		initialPassword = "Nix";
		shell = pkgs.zsh;
		isNormalUser = true;
		group = "wheel";
		extraGroups = ["video" "render" "cdrom" "optical" "docker" "libvirtd" "kvm"];
	};

	services.openssh.enable = true;

	nixpkgs.config.allowUnfree = true;

	environment.systemPackages = with pkgs; [
		pciutils
		memtest86-efi
		coreutils
		hwinfo
		mesa-demos
		nano
		wget
		curl
		sudo
		tree
		zip
		unzip
		mc
		git
		mono
		wine
		winetricks
		speechd
		exfatprogs
		python312
		v4l-utils
		easyeffects
		rnnoise-plugin
		htop
		tmux
		openrgb
		android-tools
		grub2
		msedit
		dotnet-sdk_10
		dotnet-runtime_10
		gnome-disk-utility
		ntfs3g
		fastfetch
		binutils
		file
		zstd
	];

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
	
	nix.settings.experimental-features = ["nix-command" "flakes"];
})

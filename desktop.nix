({pkgs, pkgs-unstable, ...}: {

	services.xserver.enable = true;
	services.displayManager.sddm = {
		enable = true;
		wayland.enable = true;
		theme = "astronaut";
		extraPackages = with pkgs.qt6; [
			qtsvg
			qtvirtualkeyboard
			qtmultimedia
		];
	};

	services.desktopManager.plasma6.enable = true;
	services.xserver.xkb.layout = "sk";
	services.xserver.xkb.variant = "";

	# Packages for desktop systems are now organized in dedicated modules under modules/.

	virtualisation.docker = {
		enable = true;
		enableOnBoot = true; 
		#package = pkgs.docker_29
	};

	services.sunshine.package = pkgs.sunshine.override {
		cudaSupport = true;
		cudaPackages = pkgs.cudaPackages;
	};

	services.sunshine = {
		enable = true;
		autoStart = true;  # optional: starts Sunshine automatically on login
		capSysAdmin = true;
		openFirewall = true;
	};

	virtualisation.virtualbox.host.enable = true;
	virtualisation.virtualbox.host.enableExtensionPack = true;
	virtualisation.virtualbox.host.addNetworkInterface = true;
	virtualisation.libvirtd.enable = true;
	virtualisation.libvirtd.qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
	programs.virt-manager.enable = true;
	
	users.extraGroups.vboxusers.members = [ "tachi" ];	
	users.extraGroups.i2c.members = [ "tachi" ];

	services.teamviewer.enable = true;

	services.xserver.displayManager.session = [
  	{
		name = "Steam";
		manage = "desktop";  # ← This is what Nix was missing
		start = ''
		exec ${pkgs.gamescope}/bin/gamescope \
			--fullscreen \
        	-W 3840 -H 2160 \
			--steam \
			-- \
			steam -tenfoot
		'';
	}
	{
		name = "RetroArch";
		manage = "desktop";
		start = ''
			exec ${pkgs.gamescope}/bin/gamescope \
			--fullscreen \
			-W 3840 -H 2160 \
			-- \
			retroarch
		'';
	}
	{
		name = "Kodi";
		manage = "desktop";
		start = ''
			exec ${pkgs.gamescope}/bin/gamescope \
			--fullscreen \
			-W 3840 -H 2160 \
			-- \
			kodi
		'';
	}

	];

	environment.sessionVariables = {
		XDG_CONFIG_HOME = "$HOME/.config";
		NIXOS_OZONE_WL = "1";
		MANGOHUD = "1";
		__NV_PRIME_RENDER_OFFLOAD = "1";
		__GLX_VENDOR_LIBRARY_NAME = "nvidia";
	};
	
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true;
		dedicatedServer.openFirewall = true;
		localNetworkGameTransfers.openFirewall = true;
		extraCompatPackages = with pkgs; [
			proton-ge-bin
		];
	};
})

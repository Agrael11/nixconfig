({pkgs, pkgs-unstable, ...}: {

	nixpkgs.overlays = [
		(self: super: {
		vlc = super.vlc.overrideAttrs (oldAttrs: {
			buildInputs = (oldAttrs.buildInputs or []) ++ [ super.libbluray-full ];
		});
		})
		# Overlay to redirect MakeMKV downloads to the Wayback Machine
        (final: prev: {
            makemkv = prev.makemkv.overrideAttrs (oldAttrs: {
                srcs = [
                    (prev.fetchurl {
                        url = "https://web.archive.org/web/https://www.makemkv.com/download/makemkv-bin-${oldAttrs.version}.tar.gz";
                        hash = (builtins.elemAt oldAttrs.srcs 0).outputHash or (builtins.elemAt oldAttrs.srcs 0).drvAttrs.outputHash;
                    })
                    (prev.fetchurl {
                        url = "https://web.archive.org/web/https://www.makemkv.com/download/makemkv-oss-${oldAttrs.version}.tar.gz";
                        hash = (builtins.elemAt oldAttrs.srcs 1).outputHash or (builtins.elemAt oldAttrs.srcs 1).drvAttrs.outputHash;
                    })
                ];
            });
        })
	];

	services.xserver.enable = true;
	services.displayManager.sddm = 
	{
		enable = true;
		wayland.enable = true;
		theme = "astronaut";
		extraPackages = with pkgs.qt6; [
			qtsvg
			qtvirtualkeyboard
			qtmultimedia
		];
	};

	imports = [
		./sddm-astronaut-theme.nix
	];

	services.desktopManager.plasma6.enable = true;
	services.xserver.xkb.layout = "sk";
	services.xserver.xkb.variant = "";

	environment.systemPackages = (with pkgs; [
		vlc
		brave
		gedit
		gparted
		gimp
		libreoffice
		davinci-resolve
		discord
		blender
		lutris
		gamemode
		protonup-qt
		xwayland
		vscode
		obs-studio
		filezilla
		mangohud
		gamescope
		kodi
		ffmpeg
		makemkv
		bottles
		unityhub
		appimage-run
		docker-compose
		freerdp
		qbittorrent
	]);
	

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

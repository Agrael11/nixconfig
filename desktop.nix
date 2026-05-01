({pkgs, ...}: let
  libbluray = pkgs.libbluray.override {
    withAACS = true;
    withBDplus = true;
  };
  vlc = pkgs.vlc.override { inherit libbluray; };
in {
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

	environment.systemPackages = [vlc] ++ (with pkgs; [
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
	]);
	

	virtualisation.docker = {
		enable = true;
		enableOnBoot = true; 
	};

	virtualisation.virtualbox.host.enable = true;
	virtualisation.virtualbox.host.enableExtensionPack = true;
	virtualisation.virtualbox.host.addNetworkInterface = true;
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

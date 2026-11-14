{ pkgs, ... }: {
  imports = [
    ./modules/gui/system-tools.nix
    ./modules/gui/browsers.nix
    ./modules/gui/text-editors.nix
    ./modules/gui/file-transfer.nix
    ./modules/gui/downloads.nix
    ./modules/gui/communication.nix
    ./modules/gui/media-players.nix
    ./modules/gui/video-editors.nix
    ./modules/gui/video-recording.nix
    ./modules/gui/disc-tools.nix
    ./modules/gui/image-editors.nix
    ./modules/gui/3d-tools.nix
    ./modules/gui/office.nix
    ./modules/gui/audio.nix
    ./modules/gui/compatibility.nix
    ./modules/gui/development.nix
    ./modules/gui/remote-access.nix
    ./modules/gui/virtualisation.nix
    ./modules/gui/games.nix
    ./modules/gui/game-sessions.nix
    ./modules/gui/curseforge.nix
    ./modules/gui/sddm-astronaut-theme.nix
    ./modules/gui/services/sunshine.nix
    ./modules/gui/services/teamviewer.nix
  ];

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
	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
	};

	services.xserver.xkb.layout = "sk";
	services.xserver.xkb.variant = "";

	environment.sessionVariables = {
		NIXOS_OZONE_WL = "1";
		MANGOHUD = "1";
		__NV_PRIME_RENDER_OFFLOAD = "1";
		__GLX_VENDOR_LIBRARY_NAME = "nvidia";
	};
}

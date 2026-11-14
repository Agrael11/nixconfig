{ pkgs, ... }: {
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
	};
}

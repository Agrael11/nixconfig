{ pkgs, hres, vres, extraExport, ... }: {
	services.xserver.displayManager.session = [
	{
		name = "Steam";
		manage = "desktop";  # ← This is what Nix was missing
		start = ''
			${extraExport} exec ${pkgs.gamescope}/bin/gamescope \
			--fullscreen \
		-W ${hres} -H ${vres} \
			--steam \
			-- \
			steam -tenfoot
		'';
	}
	{
		name = "RetroDeck";
		manage = "desktop";
		start = ''
			${extraExport} exec ${pkgs.gamescope}/bin/gamescope \
			--fullscreen \
			-W ${hres} -H ${vres} \
			-- \
			net.retrodeck.retrodeck
		'';
	}
	{
		name = "RetroArch";
		manage = "desktop";
		start = ''
			${extraExport} exec ${pkgs.gamescope}/bin/gamescope \
			--fullscreen \
			-W ${hres} -H ${vres} \
			-- \
			retroarch
		'';
	}
	{
		name = "Kodi";
		manage = "desktop";
		start = ''
			${extraExport} exec ${pkgs.gamescope}/bin/gamescope \
			--fullscreen \
			-W ${hres} -H ${vres} \
			-- \
			kodi
		'';
	}

	];
}

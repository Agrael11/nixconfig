{ pkgs, ... }: {
  services.flatpak.enable = true;

	system.activationScripts.updateFlatpaks = {
		text = ''
			PATH=$PATH:${pkgs.flatpak}/bin
			flatpak update --noninteractive || true
		'';
	};
}

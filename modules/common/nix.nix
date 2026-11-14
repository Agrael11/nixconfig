{ ... }: {
	nix.settings = {
		substituters = [ "https://cache.nixos.org/" ];
		trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
		trusted-users = [ "root" "tachi" ];
		experimental-features = [ "nix-command" "flakes" ];
	};
}

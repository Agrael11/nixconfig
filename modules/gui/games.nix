({ pkgs, ... }: {
  # Graphical entertainment and gaming packages.

  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraLibraries = pkgs: [ pkgs.file ];
    })
    protonup-qt
    mangohud
    gamescope
  ];

  services.flatpak.packages = [
    "net.retrodeck.retrodeck"
  ];
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

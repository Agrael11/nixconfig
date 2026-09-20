({pkgs, ...}: {

	boot.kernelPackages = pkgs.linuxPackages_latest;
	
	networking.hostName = "Desktop";
})

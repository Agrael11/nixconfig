({pkgs, lib, ...}: {
		
		boot.kernelPackages = pkgs.linuxPackages;

		networking.hostName = "Laptop";
})

{
	description = "My NixOS Configuration";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    	
		sc0710.url = "github:Nakildias/sc0710";
		grub2-themes = {
			url = "github:vinceliuice/grub2-themes";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
	
	outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, sc0710, grub2-themes }: {
		nixosConfigurations = {
			Desktop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
        		specialArgs = { 
					pkgs-unstable = import nixpkgs-unstable {
						system = "x86_64-linux";
						config.allow-unstable = true;
					};
					inherit inputs; 
				};
				modules = [
        			sc0710.nixosModules.default
					./hardware-config-desktop.nix
					./config.nix
					./config-desktop.nix
					./samba.nix
					./desktop.nix
					./retroarch-fix.nix
          			grub2-themes.nixosModules.default
				];
			};
			Laptop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
        		specialArgs = { 
					pkgs-unstable = import nixpkgs-unstable {
						system = "x86_64-linux";
						config.allow-unstable = true;
					};
					inherit inputs; 
				};
				modules = [
					./hardware-config-notebook1.nix
					./config.nix
					./config-notebook1.nix
					./samba.nix
					./desktop.nix
					./retroarch-fix.nix
          			grub2-themes.nixosModules.default
				];
			};
		};
	};
}

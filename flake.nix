{
	description = "My NixOS Configuration";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
		grub2-themes = {
			url = "github:vinceliuice/grub2-themes";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
	
	outputs = inputs@{ self, nixpkgs, grub2-themes }: {
		nixosConfigurations = {
			Desktop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
        		specialArgs = { inherit inputs; };
				modules = [
					./elgato.nix
					./hardware-config.nix
					./config.nix
					./desktop.nix
          			grub2-themes.nixosModules.default
				];
			};
		};
	};
}

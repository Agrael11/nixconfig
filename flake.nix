{
	description = "My NixOS Configuration";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
		nix-flatpak.url = "github:gmodena/nix-flatpak";
    	
		sc0710.url = "github:Nakildias/sc0710";
		grub2-themes = {
			url = "github:vinceliuice/grub2-themes";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
	
	outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, nix-flatpak, sc0710, grub2-themes }: {
		nixosConfigurations = {
			Desktop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
        		specialArgs = { 
					extraExport = "";
					hres = "3840"; 
					vres = "2160"; 
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
					./desktop.nix
          			grub2-themes.nixosModules.default
					nix-flatpak.nixosModules.nix-flatpak
				];
			};
			Laptop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
        		specialArgs = { 
					extraExport = "VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
					hres = "1920"; 
					vres = "1080"; 
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
					./desktop.nix
					grub2-themes.nixosModules.default
					nix-flatpak.nixosModules.nix-flatpak
				];
			};
		};
		devShells.x86_64-linux = let
			pkgs = import nixpkgs { system = "x86_64-linux"; };
			pkgs-unstable = import nixpkgs-unstable {
				system = "x86_64-linux";
				config.allow-unstable = true;
			};
		in {
			default = import ./devShells/devshell-gcc.nix { inherit pkgs pkgs-unstable; };
			gcc = import ./devShells/devshell-gcc.nix { inherit pkgs pkgs-unstable; };
			gamedev = import ./devShells/devshell-gamedev.nix { inherit pkgs pkgs-unstable; };
		};
	};
}

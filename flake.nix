{
	description = "My NixOS Configuration";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
		nix-flatpak.url = "github:gmodena/nix-flatpak";
    jetbrains-plugins = {
      url = "github:nix-community/nix-jetbrains-plugins";
      flake = false;
    };
    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      flake = false;
    };
    	
		sc0710.url = "github:Nakildias/sc0710";
		grub2-themes = {
			url = "github:vinceliuice/grub2-themes";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
	
	outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, nix-flatpak, sc0710, grub2-themes, jetbrains-plugins, vscode-extensions }: {
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
  						config.allowUnfree = true;
					};
					inherit inputs; 
				};
				modules = [ ./hosts/desktop/default.nix ];
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
				modules = [ ./hosts/laptop/default.nix ];
			};
		};
	};
}

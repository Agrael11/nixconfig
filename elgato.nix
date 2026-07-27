{ config, pkgs, lib, ... }:

{
  inputs = {
    # ...
    sc0710.url = "github:Nakildias/sc0710";
  };

  outputs = { self, nixpkgs, sc0710 }: {
    # replace <your-hostname> with your actual hostname
    nixosConfigurations.Desktop = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        # ...
        sc0710.nixosModules.default
      ];
    };
  };
}

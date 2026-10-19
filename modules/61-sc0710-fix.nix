({ pkgs, pkgs-unstable, ... }@args:
  (import sc0710.nixosModules.default)
    (args // {
      pkgs = pkgs // {
        stdenv = pkgs-unstable.stdenv;
      };
    })
)
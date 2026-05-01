{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      libretro = prev.libretro // {
        # We set the broken core to 'null'. 
        # The 'retroarch-full' package will see it's missing and just skip it.
        fbalpha2012 = null;
      };
    })
  ];

  environment.systemPackages = [
    pkgs.retroarch-full
  ];
}
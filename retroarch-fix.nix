{ config, pkgs, lib, ... }:

let
  # We define the patched RetroArch here in the 'let' block
  # just like your sc0710-driver example.
  fixed-retroarch = pkgs.retroarch-full.override {
    libretro = pkgs.libretro // {
      fbneo = pkgs.libretro.fbneo.overrideAttrs (oldAttrs: {
        # The 'ints.h' fix:
        # The Makefile runs from src/burner/libretro
        # We force the compiler to look in src/burner where ints.h lives
        NIX_CFLAGS_COMPILE = (oldAttrs.NIX_CFLAGS_COMPILE or "") + " -I../../src/burner";
      });
    };
  };
in
{
  # 1. Allow unfree for this module specifically if not global
  nixpkgs.config.allowUnfree = true;

  # 2. Add our fixed version to system packages
  environment.systemPackages = [
    fixed-retroarch
  ];
}
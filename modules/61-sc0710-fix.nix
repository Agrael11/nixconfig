{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

let
  sc0710Module = import inputs.sc0710.nixosModules.default;
in
  sc0710Module {
    inherit config lib;
    pkgs = pkgs // {
      stdenv = pkgs-unstable.stdenv;
    };
  }
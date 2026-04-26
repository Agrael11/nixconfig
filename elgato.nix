{ config, pkgs, lib, ... }:

let
  # The community-maintained driver for the sc0710 bridge (4K Pro / 4K60 Pro Mk.2)
  sc0710-driver = config.boot.kernelPackages.callPackage ({ stdenv, lib, fetchFromGitHub, kernel }:
    stdenv.mkDerivation {
      pname = "sc0710";
      version = "2026-02-19"; # Latest stable community fix

      src = fetchFromGitHub {
        owner = "Nakildias";
        repo = "sc0710";
        rev = "main";
        sha256 = "sha256-c7G+BfCR7WU2xyzPti/GuXMHBLLcFj1k4BKMJxmzjhE="; # Run 'nix-prefetch-url' to get current hash
      };

      nativeBuildInputs = kernel.moduleBuildDependencies;

      patchPhase = ''
        substituteInPlace lib/sc0710-video.c \
          --replace "min_queued_buffers" "min_buffers_needed"
      '';

      # We manually point KDIR to the Nix store kernel dev path
      buildPhase = ''
        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
          M=$(pwd) \
          modules
      '';

      installPhase = ''
        install -D sc0710.ko -t $out/lib/modules/${kernel.modDirVersion}/extra
      '';
    }) {};
in
{
  # 1. Inject the driver into the kernel
  boot.extraModulePackages = [ sc0710-driver ];
  
  # 2. Tell the kernel to load it
  boot.kernelModules = [ "sc0710" ];

  # 3. CRITICAL: Permissions for your user
  # Replace 'yourusername' with your actual login name!
  users.users.tachi.extraGroups = [ "video" "render" ];

  # 4. Hardware firmware (Required for Elgato)
  hardware.enableRedistributableFirmware = true;

  # 5. Udev Rules (So OBS can talk to the card)
  services.udev.extraRules = ''
    KERNEL=="video*", ATTRS{idVendor}=="12ab", ATTRS{idProduct}=="0710", GROUP="video", MODE="0660"
  '';
}
({ pkgs, ... }: {
  # Productivity tooling for command-line workflows.programs.nix-ld.enable = true;
  
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    openssl
    zlib
    libX11
    libX11.dev
  ];

  environment.systemPackages = with pkgs; [
    python312
    speechd
    exfatprogs
    git
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf

    assimp
    openal

    vulkan-loader
    vulkan-tools

    libX11

    temurin-jre-bin-25
  ] ;
})

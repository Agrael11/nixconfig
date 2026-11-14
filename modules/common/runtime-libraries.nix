{ pkgs, ... }: {
  # Preserve runtimes and compatibility libraries for packaged and external applications.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      openssl
      zlib
      libX11
      libX11.dev
      file
    ];
  };

  environment.systemPackages = with pkgs; [
    python312
    mono
    dotnet-runtime_10
    temurin-jre-bin-25
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    assimp
    openal
    vulkan-loader
    libX11
  ];
}

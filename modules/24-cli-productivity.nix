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
    rustup
    gcc
    gdb
    cmake
    ninja
    pkg-config
    git
    SDL2
    SDL2.dev
    SDL2_image
    SDL2_mixer
    SDL2_mixer.dev
    SDL2_ttf

    glm
    assimp
    openal

    vulkan-loader
    vulkan-headers
    vulkan-tools
    shaderc

    imgui
    xorgproto
    libX11
    libX11.dev

    jdk25
    maven
  ] ;

  environment.sessionVariables = {
    CPATH = "/run/current-system/sw/include";
    LIBRARY_PATH = "/run/current-system/sw/lib";
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
    CMAKE_PREFIX_PATH = "/run/current-system/sw";
  };

  environment.pathsToLink = [
     "/include" 
     "/lib/pkgconfig"
     ];
})

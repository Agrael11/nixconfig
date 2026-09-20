({pkgs, pkgs-unstable, ...}: (import ./devshell-gcc.nix { inherit pkgs pkgs-unstable; }).overrideAttrs (old: {
  buildInputs = old.buildInputs ++ (with pkgs-unstable; [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf

    glm
    assimp
    openal

    vulkan-loader
    vulkan-headers
    vulkan-tools
    shaderc

    imgui
    xorg.libX11
  ]);
}))
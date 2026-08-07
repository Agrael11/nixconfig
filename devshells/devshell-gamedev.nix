{ pkgs }:

(import ./devshell-gcc.nix { inherit pkgs; }).overrideAttrs (old: {
  packages = old.packages ++ (with pkgs; [
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

    
  ]);
})
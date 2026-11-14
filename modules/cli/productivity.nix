{ pkgs, ... }: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
     git
     codex
  ];
}

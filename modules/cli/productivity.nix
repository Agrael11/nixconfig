{ pkgs, ... }: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = [ pkgs.git ];
}

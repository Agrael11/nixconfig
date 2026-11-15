{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      if [[ "$USER" == tachi ]]; then
        ${pkgs.fastfetch}/bin/fastfetch
      fi
    '';
    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "z" ];
    };
  };

  environment.sessionVariables = {
    PATH = [ "~/.local/bin/" ];
    XDG_CONFIG_HOME = "$HOME/.config";
  };
}

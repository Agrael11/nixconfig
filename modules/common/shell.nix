{ ... }: {
  programs.zsh = {
    enable = true;
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

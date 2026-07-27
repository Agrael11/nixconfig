({ pkgs, ... }: {
  # Graphical productivity applications.

  environment.systemPackages = with pkgs; [
    libreoffice
    davinci-resolve
    blender
    gimp
    vscode
    obs-studio
    unityhub
    easyeffects
    rnnoise-plugin
  ];
})

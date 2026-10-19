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
    jetbrains.rust-rover
    jetbrains.clion
    jetbrains.rider
    jetbrains.idea
  ];
})

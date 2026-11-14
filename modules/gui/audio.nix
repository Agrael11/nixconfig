{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    easyeffects
    rnnoise-plugin
  ];

  programs.noisetorch.enable = true;
}

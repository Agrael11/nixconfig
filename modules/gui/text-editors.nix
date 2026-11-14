{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gedit
  ];
}

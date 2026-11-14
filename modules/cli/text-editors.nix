{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nano
    msedit
  ];
}

{ pkgs, ... }: {
  # Retain the existing daemon/client package; do not enable additional services.
  environment.systemPackages = with pkgs; [
    gamemode
  ];
}

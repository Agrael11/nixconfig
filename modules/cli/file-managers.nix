{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    mc
    tree
  ];
}

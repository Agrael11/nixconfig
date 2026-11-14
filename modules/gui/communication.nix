{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    discord
    thunderbird
  ];
}

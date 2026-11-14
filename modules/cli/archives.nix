{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    rar
    zip
    unzip
    zstd
    p7zip
  ];
}

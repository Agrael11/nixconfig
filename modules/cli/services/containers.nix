{ pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    #package = pkgs.docker_29
  };

  environment.systemPackages = [ pkgs.docker-compose ];
}

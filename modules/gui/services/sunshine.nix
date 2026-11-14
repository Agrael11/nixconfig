{ pkgs, ... }: {
  services.sunshine.package = pkgs.sunshine.override {
    cudaSupport = true;
    cudaPackages = pkgs.cudaPackages;
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
}

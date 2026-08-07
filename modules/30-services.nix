({ pkgs, ... }: {
  # Shared services and system settings used by all machines.

  nixpkgs.config.allowUnfree = true;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.hardware.openrgb.enable = true;
  services.flatpak.enable = true;
  services.openssh.enable = true;

  programs.partition-manager.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  programs.noisetorch.enable = true;

  i18n.defaultLocale = "sk_SK.UTF-8";
  console.keyMap = "sk-qwertz";

  time.timeZone = "Europe/Bratislava";
  time.hardwareClockInLocalTime = true;

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "z" ];
    };
  };

  documentation.enable = false;
})

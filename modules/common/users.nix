({ pkgs, ... }: {
  # User accounts, shell configuration, and sudo access.

  environment.shells = [ pkgs.zsh ];

  security.sudo.enable = true;
  security.sudo.extraRules = [
    {
      users = [ "tachi" ];
      commands = [
        {
          command = "/root/grub-switcher.sh";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  users.users.root = {
    initialPassword = "Nix";
    shell = pkgs.zsh;
  };

  users.users.tachi = {
    initialPassword = "Nix";
    shell = pkgs.zsh;
    isNormalUser = true;
    group = "wheel";
    extraGroups = [ "video" "render" "cdrom" "optical" "docker" "libvirtd" "kvm" ];
  };
})

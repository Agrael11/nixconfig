{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnome-disk-utility
    mission-center
    gparted
  ];

  security.sudo.extraRules = [
    {
      users = [ "tachi" ];
      commands = [
        {
          command = "${pkgs.mission-center}/bin/missioncenter";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  programs.partition-manager.enable = true;
}

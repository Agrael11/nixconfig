{ ... }: {
  imports = [ ../../modules/homemanager ];
  home-manager.users.tachi = import ../../modules/homemanager/tachi/laptop.nix;
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
  };
}

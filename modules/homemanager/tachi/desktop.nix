{ ... }: {
  imports = [ ./common.nix ];
  nixconfig = {
    host = "desktop";
    monitorScreen = 1;
    gpuSensors = [ "gpu/gpu1" ];
    mangohudFontSize = 28;
    fpsLimit = "0+60+120";
  };
  programs.plasma.kscreenlocker.lockOnResume = false;
  programs.plasma.powerdevil = {
    AC.powerButtonAction = "nothing";
    battery.powerButtonAction = "nothing";
    lowBattery.powerButtonAction = "nothing";
  };
}

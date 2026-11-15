{ ... }: {
  imports = [ ./common.nix ];
  nixconfig = {
    host = "laptop";
    monitorScreen = 0;
    gpuSensors = [ "gpu/gpu0" "gpu/gpu1" ];
    mangohudFontSize = 12;
    fpsLimit = "60+120+0";
  };
  programs.plasma.kscreenlocker.lockOnResume = true;
  programs.plasma.powerdevil = {
    AC = { powerButtonAction = "sleep"; whenLaptopLidClosed = "sleep";
      inhibitLidActionWhenExternalMonitorConnected = false; };
    battery = { powerButtonAction = "sleep"; whenLaptopLidClosed = "sleep";
      inhibitLidActionWhenExternalMonitorConnected = false; };
    lowBattery = { powerButtonAction = "sleep"; whenLaptopLidClosed = "sleep";
      inhibitLidActionWhenExternalMonitorConnected = false; };
  };
  programs.plasma.configFile."kcminputrc"."Libinput/1267/12433/ELAN0504:01 04F3:3091 Touchpad" = {
    DisableWhileTyping = false;
    Enabled = true;
  };
}

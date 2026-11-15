{ ... }: {
  programs.plasma = {
    configFile."powerdevilrc"."AC/Display".TurnOffDisplayWhenIdle = false;
    kscreenlocker = { autoLock = false; timeout = 0; };
    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        turnOffDisplay.idleTimeout = "never";
      };
      battery.autoSuspend = { action = "sleep"; idleTimeout = 900; };
      lowBattery.autoSuspend = { action = "sleep"; idleTimeout = 900; };
      # Keep the device's existing threshold; act on the critical-level event.
      batteryLevels.criticalAction = "sleep";
    };
  };
}

{ ... }: {
  nixpkgs.config.allowUnfree = true;

  i18n.defaultLocale = "sk_SK.UTF-8";
  console.keyMap = "sk-qwertz";

  time.timeZone = "Europe/Bratislava";
  time.hardwareClockInLocalTime = true;

  documentation.enable = false;
}

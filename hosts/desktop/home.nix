{ ... }: {
  imports = [ ../../modules/homemanager ];
  home-manager.users.tachi = import ../../modules/homemanager/tachi/desktop.nix;
  # Plasma takes the low-level inhibitor while running; this is the fallback
  # outside a graphical session. Respect inhibitors in both cases.
  services.logind.settings.Login.HandlePowerKey = "ignore";
}

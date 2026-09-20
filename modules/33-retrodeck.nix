{ config, pkgs, lib, ... }:

{
  options = {};

  config = {
    systemd.services.configure-flatpak-retrodeck = {
      description = "Deklaratívna inštalácia RetroDECK cez Flatpak";
      serviceConfig = { Type = "oneshot"; };
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        # Pridanie Flathub repozitára, ak neexistuje
        flatpak remote-add --if-not-exists flathub https://flathub.org
        # Inštalácia samotného RetroDECKu (neinteraktívne)
        flatpak install --noninteractive flathub net.retrodeck.retrodeck
      '';
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "retrodeck" ''
        exec flatpak run --filesystem=/media/retro-shares net.retrodeck.retrodeck
      '')
    ];
  };

}

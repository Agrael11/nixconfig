{ pkgs, ... }:

let
  curseforge-src = pkgs.fetchurl {
    name = "CurseForge.AppImage";
    url = "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.AppImage";
    hash = "sha256-vJpsXJabVyp6Ge+NPRwoy7yNUtlsO5xG7I1MrqUW7zc="; 
  };

   curseforge-bin = pkgs.appimageTools.wrapType2 {
    pname = "curseforge";
    version = "latest";
    src = curseforge-src;
    # Odstránené nepotrebné knižnice, ak aplikácia beží, extraPkgs netreba
  };
in {
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = [
    curseforge-bin

    (pkgs.makeDesktopItem {
      name = "curseforge";
      desktopName = "CurseForge";
      genericName = "Mod Manager";
      comment = "Manage and install mods for Minecraft and World of Warcraft";
      
      # %u odovzdá kliknutú URL adresu (curseforge://) priamo do aplikácie
      exec = "${curseforge-bin}/bin/curseforge %u";
      
      categories = [ "Game" ]; 
      icon = "joystick"; 
      terminal = false;
      type = "Application";
      
      # Zaregistruje protokol v systéme
      mimeTypes = [ "x-scheme-handler/curseforge" ];
    })
  ];
}
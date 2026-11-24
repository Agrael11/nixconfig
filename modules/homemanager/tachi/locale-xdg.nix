{ ... }: {
  home.language = {
    base = "sk_SK.UTF-8";
    time = "sk_SK.UTF-8";
  };
  nixconfig.mutable = [
    { kind = "text"; path = ".config/user-dirs.locale"; value = "sk_SK\n"; }
  ];
  xdg.userDirs = {
    enable = true;
    package = null; # Plasma's NixOS module already installs xdg-user-dirs.
    createDirectories = false;
    desktop = "/home/tachi/Desktop";
    download = "/home/tachi/Stiahnuté";
    templates = "/home/tachi/Šablóny";
    publicShare = "/home/tachi/Verejné";
    documents = "/home/tachi/Dokumenty";
    music = "/home/tachi/Hudba";
    pictures = "/home/tachi/Obrázky";
    videos = "/home/tachi/Video";
    extraConfig.PROJECTS = "/home/tachi/Projekty";
  };
  xdg.mime.enable = false; # MIME database tools remain system-owned.
  programs.plasma.configFile."plasma-localerc" = {
    Formats = {
      LANG = "sk_SK.UTF-8";
      LC_TIME = "sk_SK.UTF-8"; LC_NUMERIC = "sk_SK.UTF-8";
      LC_MONETARY = "sk_SK.UTF-8"; LC_MEASUREMENT = "sk_SK.UTF-8";
      LC_ADDRESS = "sk_SK.UTF-8"; LC_NAME = "sk_SK.UTF-8";
      LC_PAPER = "sk_SK.UTF-8"; LC_TELEPHONE = "sk_SK.UTF-8";
    };
    Translations.LANGUAGE = "sk";
  };
}

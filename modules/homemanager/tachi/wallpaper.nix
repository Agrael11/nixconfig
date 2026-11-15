{ pkgs, ... }:
let
  plugin = pkgs.runCommand "tachi-original-html-wallpaper" {} ''
    mkdir -p $out/share/plasma/wallpapers
    cp -r ${./assets/htmlwallpaper} $out/share/plasma/wallpapers/de.unkn0wn.htmlwallpaper
  '';
in {
  home.packages = [ plugin ];
  home.file."bckg/suncalc.js".source = ./assets/suncalc.js;
  home.file."bckg/SunCalc-LICENSE".source = ./assets/SunCalc-LICENSE;
  programs.plasma.startup.desktopScript.tachi-wallpaper = {
    priority = 8;
    text = ''
      desktops().forEach(function(d) {
        d.wallpaperPlugin = "de.unkn0wn.htmlwallpaper";
        d.currentConfigGroup = ["Wallpaper", "de.unkn0wn.htmlwallpaper", "General"];
        d.writeConfig("DisplayPage", "file:///home/tachi/bckg/index.html");
      });
    '';
  };
}

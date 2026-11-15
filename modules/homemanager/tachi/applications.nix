{ ... }: {
  nixconfig.mutable = [
    { kind = "ini"; path = ".config/mimeapps.list"; values."Default Applications" = {
      "x-scheme-handler/http" = "brave-browser.desktop;";
      "x-scheme-handler/https" = "brave-browser.desktop;";
      "text/html" = "brave-browser.desktop;";
    }; }
    { kind = "ini"; path = ".config/vlc/vlcrc"; values.qt.qt-privacy-ask = "0"; }
    { kind = "ini"; path = ".config/qBittorrent/qBittorrent.conf"; values = {
      BitTorrent."Session\\QueueingSystemEnabled" = "false";
      GUI."Log\\Enabled" = "false";
    }; }
    { kind = "ini"; path = ".config/mc/ini"; values = {
      "Midnight-Commander" = {
        use_internal_edit = "true";
        editor_tab_spacing = "8";
        editor_visible_tabs = "true";
        editor_visible_spaces = "true";
      };
      Panels.show_dot_files = "true";
    }; }
  ];
}

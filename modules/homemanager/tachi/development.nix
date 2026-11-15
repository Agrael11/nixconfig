{ pkgs, config, lib, ... }: {
  programs.git = {
    enable = true;
    package = null;
    settings = {
      user = { name = "Tachi"; email = "oliver.neuschl@gmail.com"; };
      safe.directory = [ "/etc/nixos" "/home/tachi/nixos" ];
      credential."https://github.com".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
      credential."https://gist.github.com".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
    };
  };
  # Keep the existing root Git config and select the HM-managed fragment last.
  nixconfig.mutable = [
    { kind = "git-include"; path = ".gitconfig"; include = "${config.xdg.configHome}/git/config"; }
    { kind = "json"; path = ".config/Code/User/settings.json"; values = {
      "git.enableSmartCommit" = true; "git.autofetch" = true;
      "explorer.confirmDragAndDrop" = false;
      "cmake.options.statusBarVisibility" = "visible";
      "cmake.pinnedCommands" = [ "workbench.action.tasks.configureTaskRunner" "workbench.action.tasks.runTask" ];
      "cmake.showOptionsMovedNotification" = false;
    }; }
  ];
  # JetBrains directories follow the installed IDE version; the updater merges
  # only KeymapManager/active_keymap and retains every other XML component.
  nixconfig.jetbrains = {
    "CLion${lib.versions.majorMinor pkgs.jetbrains.clion.version}" = "Visual Studio";
    "RustRover${lib.versions.majorMinor pkgs.jetbrains.rust-rover.version}" = "Visual Studio";
    "Rider${lib.versions.majorMinor pkgs.jetbrains.rider.version}" = "Visual Studio";
  };
}

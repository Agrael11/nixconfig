{ config, lib, pkgs, ... }:
let
  cfg = config.nixconfig;
  python = pkgs.python3;
  policy = pkgs.writeText "tachi-preferences.json" (builtins.toJSON {
    operations = cfg.mutable;
    jetbrains = cfg.jetbrains;
    wallpaper = toString ./assets;
    managedLinks = lib.mapAttrsToList (_: file: file.target) (lib.filterAttrs (_: file: file.enable) config.home.file);
    backupPaths = (lib.mapAttrsToList (_: file: file.target) (lib.filterAttrs (_: file: file.enable) config.home.file))
      ++ (map (op: op.path) cfg.mutable)
      ++ (lib.mapAttrsToList (directory: _: ".config/JetBrains/${directory}/options/linux/keymap.xml") cfg.jetbrains)
      ++ [ ".zshrc" "bckg/index.html" ".gitconfig" ".config/git/config" ".config/user-dirs.dirs"
      ".config/user-dirs.locale" ".config/plasma-org.kde.plasma.desktop-appletsrc"
      ".config/plasmashellrc" ".config/kglobalshortcutsrc" ".config/kwinrc"
      ".config/kdeglobals" ".config/plasma-localerc" ".config/kcminputrc"
      ".config/powerdevilrc" ".config/kscreenlockerrc" ".config/konsolerc"
      ".config/spectaclerc" ];
  });
in {
  options.nixconfig = {
    host = lib.mkOption { type = lib.types.enum [ "desktop" "laptop" ]; };
    monitorScreen = lib.mkOption { type = lib.types.int; };
    gpuSensors = lib.mkOption { type = lib.types.listOf lib.types.str; };
    mangohudFontSize = lib.mkOption { type = lib.types.int; };
    fpsLimit = lib.mkOption { type = lib.types.str; };
    mutable = lib.mkOption { type = lib.types.listOf lib.types.attrs; default = []; };
    jetbrains = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  };
  config = {
    home.packages = [ (pkgs.writeShellScriptBin "tachi-home-audit" ''
      if [ "$#" -eq 0 ]; then set -- --check; fi
      export PATH="${lib.makeBinPath [ pkgs.git ]}:$PATH"
      exec ${python}/bin/python ${./merge.py} --home "$HOME" --policy ${policy} "$@"
    '') ];
    # Back up before PM writes KConfig, not after. The merger plans every write
    # and rejects symlinks/malformed documents before changing any mutable file.
    home.activation.tachiPreferences = lib.hm.dag.entryBetween [ "configure-plasma" ] [ "writeBoundary" ] ''
      export PATH="${lib.makeBinPath [ pkgs.git ]}:$PATH"
      $DRY_RUN_CMD ${python}/bin/python ${./merge.py} --home "$HOME" --policy ${policy} --apply
    '';
    xdg.configFile."nixconfig/preferences-policy.json".source = policy;
  };
}

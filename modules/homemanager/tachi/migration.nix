{ config, lib, pkgs, ... }:
let
  cfg = config.nixconfig;
  python = pkgs.python3;
  tools = pkgs.runCommand "tachi-home-migration-tools" {} ''
    mkdir -p "$out"
    cp ${./merge.py} "$out/merge.py"
    cp ${./maintenance.py} "$out/maintenance.py"
  '';
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
      exec ${python}/bin/python ${tools}/merge.py --home "$HOME" --policy ${policy} "$@"
    '') ];
    # Back up before PM writes KConfig, not after. The merger plans every write
    # and rejects symlinks/malformed documents before changing any mutable file.
    # Keep the FD open until the activation shell exits, including PM's writes.
    # The merger inherits the same lock rather than deadlocking on a second one.
    home.activation.tachiMaintenanceLock = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      if [[ -z "''${DRY_RUN_CMD:-}" ]]; then
        tachiLockPath=$(${python}/bin/python ${tools}/maintenance.py --home "$HOME" --prepare-lock)
        exec {tachiMaintenanceLockFd}>"$tachiLockPath"
        ${pkgs.util-linux}/bin/flock -n "$tachiMaintenanceLockFd" || {
          echo "Home Manager migration/rollback/cleanup is active; retry later." >&2
          exit 1
        }
      fi
    '';
    home.activation.tachiPreferences = lib.hm.dag.entryBetween [ "configure-plasma" ] [ "writeBoundary" ] ''
      export PATH="${lib.makeBinPath [ pkgs.git ]}:$PATH"
      $DRY_RUN_CMD ${python}/bin/python ${tools}/merge.py --home "$HOME" --policy ${policy} --apply --lock-fd "''${tachiMaintenanceLockFd:--1}"
    '';
    xdg.configFile."nixconfig/preferences-policy.json".source = policy;
  };
}

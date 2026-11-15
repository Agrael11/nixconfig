hosts: builtins.mapAttrs (_: h: let u = h.config.home-manager.users.tachi; in {
  generation = toString u.home.activationPackage;
  files = builtins.mapAttrs (_: f: { inherit (f) target force; source = toString f.source; })
    (h.pkgs.lib.filterAttrs (_: f: f.enable) u.home.file);
  kconfig = u.programs.plasma.configFile;
  userPackages = map (p: p.name) u.home.packages;
}) hosts

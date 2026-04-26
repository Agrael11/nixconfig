({ pkgs, ... }: {

environment.systemPackages = [
  (pkgs.retroarch.withCores (cores:
    pkgs.lib.filter pkgs.lib.isDerivation (builtins.attrValues cores)
  ))
];
})

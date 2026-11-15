{ lib, ... }: {
  # PM's native modules emit null for many unset options. Its writer interprets
  # null as deletion even with overrideConfig=false. Only declared preferences
  # belong to this migration; keep existing values for every unset native option.
  # Deliberate key deletion must be implemented as a separately reviewed change.
  options.programs.plasma.configFile = lib.mkOption {
    apply = files: lib.mapAttrs (_: groups:
      lib.mapAttrs (_: entries:
        lib.filterAttrs (_: entry: entry.value != null || entry.persistent) entries
      ) groups
    ) files;
  };
}

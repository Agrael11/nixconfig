({ pkgs, ... }: {
  # Custom package overlays for desktop builds.
  nixpkgs.overlays = [
    (self: super: {
      vlc = super.vlc.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [ super.libbluray-full ];
      });
    })

    # Overlay to redirect MakeMKV downloads to the Wayback Machine
    (final: prev: {
      makemkv = prev.makemkv.overrideAttrs (oldAttrs: {
        srcs = [
          (prev.fetchurl {
            url = "https://web.archive.org/web/https://www.makemkv.com/download/makemkv-bin-${oldAttrs.version}.tar.gz";
            hash = (builtins.elemAt oldAttrs.srcs 0).outputHash or (builtins.elemAt oldAttrs.srcs 0).drvAttrs.outputHash;
          })
          (prev.fetchurl {
            url = "https://web.archive.org/web/https://www.makemkv.com/download/makemkv-oss-${oldAttrs.version}.tar.gz";
            hash = (builtins.elemAt oldAttrs.srcs 1).outputHash or (builtins.elemAt oldAttrs.srcs 1).drvAttrs.outputHash;
          })
        ];
      });
    })
  ];
})

({ ... }: {
  # Custom package overlays for graphical applications.
  nixpkgs.overlays = [
    (self: super: {
      vlc = super.vlc.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [ super.libbluray-full ];
      });
    })


    (final: prev: {
      makemkv = prev.makemkv.overrideAttrs (old: rec {
        version = "2.0.0";

        srcs = [
          (prev.fetchurl {
            url = "https://www.makemkv.com/download/makemkv-oss-${version}.tar.gz";
            hash = "sha256-Q1MWstIZ60jIgFJlV63dB2tfXm3lFxQkx2UfnKyVsWE=";
          })
          (prev.fetchurl {
            url = "https://www.makemkv.com/download/makemkv-bin-${version}.tar.gz";
            hash = "sha256-8SZedIdaGG79+7vsdFmmTpaQM1FeU8vE2AXwo3TwoSQ=";
          })
        ];
      });
    })
  ];
})

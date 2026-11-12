({ pkgs, ... }: {
  # Custom package overlays for desktop builds.
  nixpkgs.overlays = [
    (self: super: {
      vlc = super.vlc.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [ super.libbluray-full ];
      });
    })

    (final: prev: {
      makmkv = pkgs.makemkv.overrideAttrs (oldAttrs: rec {
        version = "2.0.0";
        
        src_bin = pkgs.fetchurl {
          url = "https://makemkv.com{version}.tar.gz";
          hash = "sha256-Y7JNeF5SZ9kITGFqQ+vuU8Qu5lCDT2r/rzPE6pLQzlU="; # If this matches the 404 hash, swap to lib.fakeHash first!
        };

        src_oss = pkgs.fetchurl {
          url = "https://makemkv.com{version}.tar.gz";
          hash = pkgs.lib.fakeHash; 
        };
      });
    })

    (final: prev: {
      vscode = prev.vscode.overrideAttrs (old: {
        prePatch = (old.prePatch or "") + ''
          mkdir -p resources/app/node_modules/@vscode/ripgrep/bin
          touch resources/app/node_modules/@vscode/ripgrep/bin/rg
        '';
      });
    })
  ];
})

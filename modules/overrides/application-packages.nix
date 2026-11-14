({ ... }: {
  # Custom package overlays for graphical applications.
  nixpkgs.overlays = [
    (self: super: {
      vlc = super.vlc.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [ super.libbluray-full ];
      });
    })

  ];
})

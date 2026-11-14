{ pkgs, ... }: {
  # w3m includes w3mimgdisplay (the equivalent of w3m-img).
  environment.systemPackages = [
    (pkgs.w3m.override {
      graphicsSupport = true;
      x11Support = true;
    })
  ];
}

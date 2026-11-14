{ pkgs, ... }: {
  # Graphics diagnostics; some commands require a display or graphics device.
  environment.systemPackages = with pkgs; [
    mesa-demos
    vulkan-tools
  ];
}

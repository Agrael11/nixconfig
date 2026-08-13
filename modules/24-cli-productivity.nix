({ pkgs, ... }: {
  # Productivity tooling for command-line workflows.

  environment.systemPackages = with pkgs; [
    python312
    speechd
    exfatprogs
  ];
})

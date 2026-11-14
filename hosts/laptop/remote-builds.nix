{ lib, ... }: {
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "Desktop.local";
      protocol = "ssh-ng";
      sshUser = "nix-ssh";
      sshKey = "/var/lib/nix-remote-build/id_ed25519";
      system = "x86_64-linux";
      maxJobs = 1;
      # Relative remote-builder weight; does not prohibit local scheduling.
      speedFactor = 2;
      supportedFeatures = [ "big-parallel" "kvm" "nixos-test" "benchmark" ];
    }
  ];

  nix.settings = {
    builders-use-substitutes = true;
    # Match nixupdate's defaults, including when building without the script.
    # CLI -j/-c overrides remain effective for local builds.
    max-jobs = lib.mkDefault 2;
    cores = lib.mkDefault 4;
  };

  # Verified directly from the physical Desktop, not from an SSH key scan.
  programs.ssh.knownHosts.desktop-builder = {
    hostNames = [ "Desktop.local" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0/99b1bqJbSHYJiZF0xkzYgrqZaNJzPBK+/HPAbJ/p";
  };
  programs.ssh.extraConfig = ''
    Match host Desktop.local user nix-ssh
      BatchMode yes
      IdentitiesOnly yes
      StrictHostKeyChecking yes
      ConnectTimeout 5
      ConnectionAttempts 1
      ServerAliveInterval 15
      ServerAliveCountMax 2
    Match all
  '';
}

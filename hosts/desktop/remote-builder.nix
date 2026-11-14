{ lib, ... }: {
  # Nix-only SSH account: no interactive shell, PTY, tunnels or forwarding.
  nix.sshServe = {
    enable = true;
    protocol = "ssh-ng";
    trusted = true;
  };

  # ssh-ng uses the builder's cores setting, rather than Laptop's CLI value.
  # Keep the default conservative on this interactive 28-thread / 32 GiB host.
  nix.settings.cores = lib.mkDefault 4;

  # Keep authentication material outside Git and the Nix store. No key means
  # this account cannot authenticate; install only Laptop's dedicated public key.
  services.openssh.extraConfig = ''
    Match User nix-ssh
      AuthorizedKeysFile /var/lib/nix-remote-builder/authorized_keys
      AuthenticationMethods publickey
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      DisableForwarding yes
    Match All
  '';

  systemd.tmpfiles.rules = [
    "d /var/lib/nix-remote-builder 0755 root root -"
  ];
}

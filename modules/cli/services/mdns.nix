{ ... }: {
  # Avahi is already enabled; let getent, SSH and Nix resolve .local names.
  services.avahi.nssmdns4 = true;
}

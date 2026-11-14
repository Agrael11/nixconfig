{ ... }: {
  security.sudo.extraConfig = ''
    Defaults pwfeedback
    Defaults timestamp_timeout=-1
  '';
}

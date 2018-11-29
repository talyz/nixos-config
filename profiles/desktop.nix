{
  imports = [
    ./common.nix
    ./common-graphical.nix
    ./gnome.nix
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}

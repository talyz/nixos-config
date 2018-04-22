{ config, pkgs, ... }:

{
  nix.buildCores = 0;
  
  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget
    ag
    gnupg
    stow
    file
    git
    htop
    fzf
    curl
    sshfs-fuse
    pv
    ripgrep
    openssh
    pciutils
    usbutils
    screen
  ];

  programs.fish.enable = true;
  services.emacs.enable = true;
}

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./home-manager/nixos
      ./gnome.nix
      ./exwm.nix
      ./emacs.nix
      ./persistence.nix
      ./common-graphical.nix
    ];
}

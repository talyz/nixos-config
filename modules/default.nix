{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./gnome.nix
      ./exwm.nix
      ./emacs.nix
      ./persistence.nix
      ./common-graphical.nix
    ];
}

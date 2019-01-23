{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./laptop.nix
      ./gnome.nix
      ./exwm.nix
      ./emacs.nix
    ];
}

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./gnome.nix
      ./exwm.nix
      ./emacs.nix
    ];
}

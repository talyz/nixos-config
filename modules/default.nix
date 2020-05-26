{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./home-manager/nixos
      ./gnome.nix
      ./exwm.nix
      ./emacs.nix
      ./impermanence/nixos.nix
      ./common-graphical.nix
      ./media-center.nix
    ];
}

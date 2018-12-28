{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./laptop.nix
      ./gnome.nix
    ];
}

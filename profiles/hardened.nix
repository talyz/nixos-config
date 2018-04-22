{ pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/hardened.nix>
  ];

  boot.kernelPackages = pkgs.linuxPackages_hardened_copperhead;
}

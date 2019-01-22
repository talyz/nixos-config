{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    [
      skype
      slack
      nomachine-client
    ];

  virtualisation.virtualbox.host.enable = true;
}

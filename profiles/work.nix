{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    [
      skype
      slack
      nomachine-client
    ];
}

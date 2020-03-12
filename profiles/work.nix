{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    [
      slack
      nomachine-client
    ];

  # virtualisation.libvirtd.enable = true;
  # virtualisation.libvirtd.qemuRunAsRoot = false;
  # virtualisation.libvirtd.onShutdown = "shutdown";
  # users.users.talyz.extraGroups = [ "libvirtd" ];
  # networking.firewall.checkReversePath = false;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.package = pkgs.virtualbox.override {
    enable32bitGuests = false;
  };
  virtualisation.virtualbox.host.enableExtensionPack = true;

  virtualisation.docker.enable = true;

  users.users.talyz.extraGroups = [ "vboxusers" "docker" ];
}

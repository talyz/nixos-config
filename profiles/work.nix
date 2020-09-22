{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    [
      slack
      nomachine-client
    ];

  programs.ssh.extraConfig = ''
    GSSAPIAuthentication yes
  '';

  # virtualisation.libvirtd.enable = true;
  # virtualisation.libvirtd.qemuRunAsRoot = false;
  # virtualisation.libvirtd.onShutdown = "shutdown";
  # users.users.talyz.extraGroups = [ "libvirtd" ];
  # networking.firewall.checkReversePath = false;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;

  users.users.talyz.extraGroups = [ "vboxusers" ];

  services.avahi.browseDomains = [ "internal.xlnaudio.com" ];
}

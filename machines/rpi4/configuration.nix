{ config, pkgs, lib, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/modules/nixpkgs"
    "nixos-config=/etc/nixos/machines/${config.networking.hostName}/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    ../../modules
  ];

  # Enable GPU acceleration
  # hardware.raspberry-pi."4".fkms-3d.enable = true;
  # hardware.bluetooth.enable = true;

  talyz.domain.internal.runControlServer = true;
  talyz.domain.external.updateDynDNS = true;
  talyz.emacs.enable = false;

  #boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.deviceTree.kernelPackage = pkgs.linuxPackages_latest.kernel;
  # hardware.deviceTree.overlays = [ pkgs.device-tree_rpi.overlays ];
  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  hardware.enableRedistributableFirmware = true;


  ### Network configuration ###

  networking.hostName = "rpi4";
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks."wired" = {
    enable = true;
    matchConfig.Name = "end0";
    DHCP = "no";
    address = [ "192.168.1.11/24" ];
    gateway = [ "192.168.1.1" ];
  };

  services.resolved.enable = true;
  services.resolved.extraConfig = ''
    DNS=192.168.1.1
  '';

  networking.networkmanager.enable = false;

  networking.firewall = {
    enable = true;
    allowPing = true;
  };


  ### File system configuration ###

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };


  system.stateVersion = "24.11";
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../../modules
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  talyz.gnome.enable = true;
  talyz.media-center.enable = true;

  # Video drivers
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Make /tmp a tmpfs mount.
  boot.tmpOnTmpfs = true;

  # Use the latest kernel.
  #boot.kernelPackages = pkgs.linuxPackages_hardened;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel modules required in the initrd to boot.
  boot.initrd.availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  # Kernel modules to load in the second stage of boot.
  boot.kernelModules = [ "kvm-amd" "nct6775" ];


  ### Network configuration ###

  networking.hostName = "raine";
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks."wired" = {
    enable = true;
    matchConfig.Name = "enp9s0";
    DHCP = "no";
    address = [ "192.168.1.128/24" ];
    gateway = [ "192.168.1.1" ];
  };

  services.resolved.enable = true;
  services.resolved.extraConfig = ''
    DNS=192.168.1.1
  '';

  # Disable networkmanager.
  networking.networkmanager.enable = false;

  # Enable firewall
  networking.firewall = {
    enable = true;
    allowPing = true;
  # Open ports in the firewall.
  # allowedTCPPorts = [ ... ];
  # allowedUDPPorts = [ ... ];
  };


  ### File system configuration ###

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/f9bd2426-07d1-4874-923c-e9e63adc8122";

  fileSystems."/" = {
    device = "/dev/root_vg/root";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/home" = {
    device = "/dev/root_vg/root";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/root_vg/root";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/70DE-7DAC";
    fsType = "vfat";
  };

  fileSystems."/media/raid" = {
    device = "/dev/mapper/raid";
    fsType = "btrfs";
    options = [ "subvol=subvol_root" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/19c066af-f5f3-498b-aa45-078350e554a4";
      keyFile = "/mnt-root/etc/raid_keyfile";
      label = "raid";
    };
  };
      
  swapDevices = [
    {
      device = "/dev/root_vg/swap";
    }
  ];

  nix.maxJobs = lib.mkDefault 8;

  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../../profiles/common.nix
    ../../modules
  ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  talyz.gnome.enable = true;
  talyz.media-center.enable = true;

  # Video drivers
  services.xserver.videoDrivers = [ "intel" ];
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel ];
  # services.xserver.deviceSection = ''
  #   Option        "Tearfree"      "true"
  # '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Make /tmp a tmpfs mount.
  boot.tmpOnTmpfs = true;

  # Use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_hardened;
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel modules required in the initrd to boot.
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  # Kernel modules to load in the second stage of boot.
  boot.kernelModules = [ "kvm-intel" ];


  ### Network configuration ###

  networking.hostName = "raine";
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks."wired" = {
    enable = true;
    matchConfig.Name = "enp4s0";
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

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/fe4b8be3-10f6-42c7-bd7d-f4444f8f23bb";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/94ea8967-7223-4a82-8b0a-ecd4b2c9a97f";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/94ea8967-7223-4a82-8b0a-ecd4b2c9a97f";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/94ea8967-7223-4a82-8b0a-ecd4b2c9a97f";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/925D-040F";
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
  system.stateVersion = "19.09"; # Did you read the comment?

}


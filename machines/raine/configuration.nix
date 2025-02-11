{ config, pkgs, lib, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/machines/${config.networking.hostName}/nixpkgs"
    "nixos-config=/etc/nixos/machines/${config.networking.hostName}/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    ../../modules
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  talyz.gnome.enable = true;

  talyz.media-center.enable = true;
  talyz.home-assistant.enable = true;
  talyz.vaultwarden.enable = true;
  talyz.immich.enable = true;
  talyz.nextcloud.enable = true;

  talyz.backups.time = "03:00";
  talyz.backups.paths = [
    "/media/raid/old"
    "/media/raid/musik"
  ];

  programs.steam.enable = true;

  # Video drivers
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Make /tmp a tmpfs mount.
  boot.tmp.useTmpfs = true;

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
    address = [ "192.168.1.10/24" ];
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

  talyz.ephemeralRoot.enable = true;

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/f9bd2426-07d1-4874-923c-e9e63adc8122";

  fileSystems."/" = {
    device = "/dev/root_vg/root";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/nix" = {
    device = "/dev/root_vg/root";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/persistent" = {
    device = "/dev/root_vg/root";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=persistent" ];
  };

  fileSystems."/cache" = {
    device = "/dev/root_vg/root";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=cache" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/70DE-7DAC";
    fsType = "vfat";
    options = [ "umask=077" ];
  };

  swapDevices = [
    {
      device = "/dev/root_vg/swap";
    }
  ];


  ### Media RAID ###

  boot.swraid.enable = true;

  fileSystems."/media/raid" = {
    depends = [ "/persistent" ];
    device = "/dev/mapper/raid";
    fsType = "btrfs";
    options = [ "subvol=subvol_root" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-id/md-uuid-fc6f63ab:d3e35ce5:1f7b4ac6:34aa23b1";
      keyFile = "/persistent/etc/raid_keyfile";
      label = "raid";
    };
  };

  boot.initrd.luks.devices.raid.crypttabExtraOpts = [ "nofail" ];


  nix.settings.max-jobs = lib.mkDefault 4;

  system.stateVersion = "24.05";
}

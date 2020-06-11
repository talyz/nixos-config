# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, modulesPath, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/machines/${config.networking.hostName}/nixpkgs"
    "nixos-config=/etc/nixos/machines/${config.networking.hostName}/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../profiles/common.nix
    ../../profiles/work.nix
    ../../modules
  ];

  talyz.gnome.enable = true;
  talyz.exwm.enable = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  hardware.bluetooth.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Make /tmp a tmpfs mount.
  boot.tmpOnTmpfs = true;

  networking.hostName = "evals";

  services.xserver.videoDrivers = [ "amdgpu" ];

  # TrackPoint
  boot.kernelPatches = [{ name = "trackpoint-scrolling"; patch = ../../trackpoint.patch; }];
  services.xserver.inputClassSections = [
    ''
      Identifier     "TrackPoint configuration"
      MatchProduct   "TrackPoint"
      Option "AccelSpeed" "0.6"
    ''
  ];

  environment.persistence = {
    targetDir = "/persistent";
    root = {
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/libvirt"
      ];
    };
    etc = {
      directories = [
        "nixos"
        "NetworkManager/system-connections"
      ];
      files = [ "machine-id" ];
    };
  };

  users.mutableUsers = false;
  users.users.talyz.passwordFile = "/persistent/password_talyz";
  users.users.root.passwordFile = "/persistent/password_root";

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/cec990ff-a4d6-410d-841d-0bc3a0e4c888";

  fileSystems."/" =
    { device = "/dev/root_vg/root";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
      mv /btrfs_tmp/root "/btrfs_tmp/old_root_$(date "+%Y-%m-%-d_%H:%M:%S")"
    fi
    btrfs subvolume create /btrfs_tmp/root
    sync
    umount /btrfs_tmp
  '';

  fileSystems."/persistent" =
    { device = "/dev/root_vg/root";
      neededForBoot = true;
      fsType = "btrfs";
      options = [ "subvol=persistent" ];
    };

  fileSystems."/nix" =
    { device = "/dev/root_vg/root";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D95D-921A";
      fsType = "vfat";
    };
  
  swapDevices = [{
    device = "/dev/root_vg/swap";
  }];

  nix.maxJobs = lib.mkDefault 2;

  # Enable firewall
  networking.firewall = {
    enable = true;
    allowPing = true;
  # Open ports in the firewall.
  # allowedTCPPorts = [ ... ];
  # allowedUDPPorts = [ ... ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}

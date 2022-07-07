{ config, lib, pkgs, modulesPath, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/machines/${config.networking.hostName}/nixpkgs"
    "nixos-config=/etc/nixos/machines/${config.networking.hostName}/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules
  ];

  talyz.gnome.enable = true;
  talyz.exwm.enable = true;

  talyz.work.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  hardware.bluetooth.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Make /tmp a tmpfs mount.
  # boot.tmpOnTmpfs = true;

  networking.hostName = "trace";

  # Video drivers
  services.xserver.videoDrivers = [ "intel" ];
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel ];
  services.xserver.deviceSection = ''
    Option        "Tearfree"      "true"
  '';

  # TrackPoint
  services.xserver.inputClassSections = [
    ''
      Identifier     "TrackPoint configuration"
      MatchProduct   "TrackPoint"
      Option "AccelSpeed" "0.6"
    ''
  ];

  home-manager.users.${config.talyz.username} = { lib, ... }:
    {
      dconf.settings = {
        "org/gnome/desktop/peripherals/touchpad".speed = 0.20;
        "org/gnome/desktop/peripherals/mouse".speed = 0.20;
      };
    };

  services.power-profiles-daemon.enable = false;

  talyz.ephemeralRoot.enable = true;

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/45a3728f-2d14-4e0b-8547-22a347b112ca";
  boot.initrd.luks.devices."cryptroot".allowDiscards = true;

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
    { device = "/dev/disk/by-uuid/F276-B050";
      fsType = "vfat";
    };

  swapDevices = [{
    device = "/dev/root_vg/swap";
  }];

  nix.maxJobs = lib.mkDefault 4;

  # Enable firewall
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.05"; # Did you read the comment?
}

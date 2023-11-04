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

  services.fprintd.enable = true;

  services.power-profiles-daemon.enable = false;

  talyz.ephemeralRoot.enable = true;

  fileSystems."/" =
    { device = "/dev/root_vg/root";
      fsType = "btrfs";
      options = [ "subvol=root" "noatime" ];
    };

  boot.initrd =
    let
      rootReset = ''
        mkdir /btrfs_tmp
        mount /dev/root_vg/root /btrfs_tmp
        if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$i"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';
    in
      {
        availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
        kernelModules = [ "dm-snapshot" ];
        luks.devices."cryptroot".device = "/dev/disk/by-uuid/e16e9123-b1bb-4480-8557-3bfcdd503a95";
        luks.devices."cryptroot".allowDiscards = true;
        postDeviceCommands = lib.mkAfter rootReset;
      };

  fileSystems."/persistent" =
    { device = "/dev/root_vg/root";
      neededForBoot = true;
      fsType = "btrfs";
      options = [ "subvol=persistent" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/root_vg/root";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F3F5-A079";
      fsType = "vfat";
      options = [ "noatime" ];
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
  system.stateVersion = "22.11"; # Did you read the comment?
}

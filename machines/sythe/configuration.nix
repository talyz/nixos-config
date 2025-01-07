{ config, lib, pkgs, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/modules/nixpkgs"
    "nixos-config=/etc/nixos/machines/sythe/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    # "${pkgs.path}/nixos/modules/installer/scan/not-detected.nix"
    ../../modules
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  talyz.hyprland.enable = true;
  talyz.gnome.enable = true;
  talyz.work.enable = true;

  environment.enableDebugInfo = true;

  services.netdata.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.amdgpu.initrd.enable = true;
  hardware.amdgpu.opencl.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # boot.kernelPatches = [{ name = "trackpoint-scrolling"; patch = ../../trackpoint.patch; }];

  # Kernel modules to load in the second stage of boot.
  boot.kernelModules = [ "kvm-amd" ];
  #boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

  # Kernel modules required in the initrd to boot.
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];

  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1
  '';

  networking.hostName = "sythe";

  talyz.ephemeralRoot.enable = true;

  # evdev:name:TPPS/2 Synaptics TrackPoint:dmi:bvn*:bvr*:bd*:svnLENOVO:pn*:pvrThinkPadT14sGen4:*
  #  POINTINGSTICK_SENSITIVITY=200
  services.udev.extraHwdb = ''
    evdev:input:b0003v04F3p1130*
     KEYBOARD_KEY_90001=btn_right
     KEYBOARD_KEY_90002=btn_left
  '';
  # environment.etc."libinput/local-overrides.quirks".text = ''
  #   [Trackpoint Override]
  #   MatchName=*TPPS/2 Synaptics TrackPoint
  #   AttrTrackpointMultiplier=0.4
  # '';
  # home-manager.users.${config.talyz.username} = { lib, ... }:
  #   {
  #     dconf.settings = {
  #       "org/gnome/desktop/peripherals/pointingstick".accel-profile = "flat";
  #     };
  #   };

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
        systemd.enable = true;
        systemd.services = {
          root-reset = {
            wantedBy = [ "initrd-root-device.target" ];
            wants = [ "dev-root_vg-root.device" ];
            after = [ "dev-root_vg-root.device" ];
            before = [ "sysroot.mount" ];
            serviceConfig.Type = "oneshot";
            script = rootReset;
          };
        };

        luks.devices."cryptroot".device = "/dev/disk/by-uuid/48dbeabc-6c2f-44b3-a463-62245bd2759e";
        # Kernel modules required in the initrd to boot.
        availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" ];
        kernelModules = [ "dm-snapshot" ];
      };
  services.fprintd.enable = true;


  ### File system configuration ###

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/48dbeabc-6c2f-44b3-a463-62245bd2759e";

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


  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7569-18E8";
    fsType = "vfat";
    options = [ "umask=077" ];
  };

  swapDevices = [
    {
      device = "/dev/root_vg/swap";
    }
  ];

  # services.snapper.configs = {
  #   home = {
  #     SUBVOLUME = "/home";
  #     ALLOW_USERS = [ "talyz" ];
  #     TIMELINE_CREATE = true;
  #     TIMELINE_CLEANUP = true;
  #     TIMELINE_LIMIT_HOURLY = 12;
  #     TIMELINE_LIMIT_DAILY = 5;
  #     TIMELINE_LIMIT_WEEKLY = 0;
  #     TIMELINE_LIMIT_MONTHLY = 0;
  #     TIMELINE_LIMIT_YEARLY = 0;
  #   };
  # };

  nix.settings.max-jobs = lib.mkDefault 4;

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  system.stateVersion = "23.11";
}

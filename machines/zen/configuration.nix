# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../../profiles/common.nix
    ../../profiles/work.nix
    ../../modules
    #./profiles/hardened.nix
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  talyz.gnome.enable = true;
  #talyz.exwm.enable = true;

  # AMD GPU drivers
  # boot.kernelPatches = [
  #   { name = "amdgpu-config";
  #     patch = null;
  #     extraConfig = ''
  #       DRM_AMD_DC_DCN1_0 y
  #     '';
  #   }
  # ];

  services.xserver.videoDrivers = [ "amdgpu" ];
  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Make /tmp a tmpfs mount.
  boot.tmpOnTmpfs = true;

  # Use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_hardened;
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel modules required in the initrd to boot.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];

  # Kernel modules to load in the second stage of boot.
  boot.kernelModules = [ "kvm-amd" "lm92" "nct6775" ];
  #boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

  networking.hostName = "zen";

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/4e259096-3b45-44ae-b3fb-0b5ab99e888a";

  fileSystems."/" =
    { device = "/dev/root_vg/root";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/nix" =
    { device = "/dev/root_vg/root";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/home" =
    { device = "/dev/root_vg/root";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/69ED-0001";
      fsType = "vfat";
    };

  fileSystems."/home/talyz/dropbox" =
    { device = "/dev/root_vg/dropbox";
      fsType = "ext4";
    };

  swapDevices = [
    {
      device = "/dev/root_vg/swap";
    }
  ];

  nix.maxJobs = lib.mkDefault 8;
  
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
  system.stateVersion = "18.09"; # Did you read the comment?
}

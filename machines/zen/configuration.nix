{ config, lib, pkgs, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/machines/zen/nixpkgs"
    "nixos-config=/etc/nixos/machines/zen/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../../modules
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  talyz.gnome.enable = true;
  # Can't use wayland because of Synergy :(
  talyz.gnome.useWayland = false;
  #talyz.exwm.enable = true;

  talyz.work.enable = true;
  programs.steam.enable = true;

  environment.enableDebugInfo = true;

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

  boot.kernelPatches = [{ name = "trackpoint-scrolling"; patch = ../../trackpoint.patch; }];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel modules required in the initrd to boot.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];

  # Kernel modules to load in the second stage of boot.
  boot.kernelModules = [ "kvm-amd" "nct6775" ];
  #boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

  networking.hostName = "zen";

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/debb17e3-71fc-471a-b9eb-ee3361fae721";

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
    { device = "/dev/disk/by-uuid/6A31-12B4";
      fsType = "vfat";
    };

  swapDevices = [
    {
      device = "/dev/root_vg/swap";
    }
  ];

  nix.maxJobs = lib.mkDefault 8;

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  system.stateVersion = "18.09";
}

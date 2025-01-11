{ config, lib, pkgs, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/machines/zen/nixpkgs"
    "nixos-config=/etc/nixos/machines/zen/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    ../../modules
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  talyz.gnome.enable = true;
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
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "r8169" ];

  # Kernel modules to load in the second stage of boot.
  boot.kernelModules = [ "kvm-amd" "nct6775" ];
  #boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1
  '';

  networking.hostName = "zen";

  #boot.kernelParams = [ "ip=dhcp" ];
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.authorizedKeys = config.users.users.talyz.openssh.authorizedKeys.keys;
  boot.initrd.network.ssh.port = 2222;
  boot.initrd.network.ssh.hostKeys = [
    "/etc/secrets/initrd/ssh_host_rsa_key"
    "/etc/secrets/initrd/ssh_host_ed25519_key"
  ];

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/f1a4b6f5-63e3-4723-9bcc-b82ffa9a83f6";

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
      options = [ "umask=077" ];
    };

  swapDevices = [
    {
      device = "/dev/root_vg/swap";
    }
  ];

  nix.settings.max-jobs = lib.mkDefault 4;

  nix.extraOptions = ''
    secret-key-files = /etc/nix/cache-priv-key.pem
  '';

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6vWa3ZSi/PukAt/CKgoGMA7qEGxc6mJiC1Tbd7kXvGD0NcHIYTRjDwip+Xk1d9///Ql2347wTRf442Dpsd/DqS0rVkj/A3DwYdsxjQJijaS3FfuQ5GqEvKmPv+n0tkpNhrNi/g7dCzvIMZs0Yfp8gxmrBGRgauk39qk4LFGOHarZQYFJRvl1CWDbamfAztDCbgWaeo968KWNjHeMmfcStV3iVLqV9kj6PPs60Scg/yy4JlppnFMKLiH8IAhHEeslzJ15Cfs8RBaYvpOIFT4fjThFMRrp/aUN5ZNHl6MjfVzS8hQtYXnqM2rqv1uhv33uR/zLjvWkA5zVjedYeSR6Y2lvNeFsIWVIebQWGdz+Yo6/lzqQ3zfNieLabjRO2xK1iA6WLFLAsVcZRu8wpwDNuvzeQTOQL5EMGf8HWuRkwEpPqYz34KVPoKWiJjN+KGzPHgGPTa0YVzjVSBVqMyseRpf68BIX4UShMMxWt+a+k7JskYBBSVgB6AfiTUL0fD1Pl8h1e6pDIk96/zdkoi2GY2klZGT47Dqxp4iQ1OB8QDyytwseKoUszl5Jm/K0e1Hgby0dxnubJoUvz89xZ2q9ChZ2785KslfNGy72QszABX1qWPRoZKzoFCM9X9avZn7vtKQU1LHTl9kOvQxLd3JYstD2kylTl+NpGc947wTnorQ== nixbld@flora-2020-03-17"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCptNGg+82SJDZpWla9qTt70LPbhqOTOyCxE1R3g1v2Vs0CFxS1qlmrU8ZQQpQLH6Y98iVBQ5P+MJpmNiogBGKiitF54yHkLiC6EKAyxtraT7/D1Kv1/yxf0njZXD2AiAOyDihxHlXH7chYfui2sILibHfC2IsEurLJBrPgmpMaMFuuMdFyfz6eKutDOvuwceG6G2FMCMQ5nUIzDdtqnE8u29BxIIqxSFmYzTylvOPznfaAyUyweeWWus00Rmy7xP6pSO2lxWjSbVFyzeoQmTS3tepbWnYsV7bpb+kep2PbLfaXMolgh5r2emoi+6qojK7i7ocZZWN2lbn5Y0ZLP9FaVXWTQ+Wk0S60ys3eBJvOEQ85mtGQ2r6/T6bRAkwTSHj3uU1w6vxFyeciO85gu8rhBaL0fQ36713GZHoCud1RGKvriRbpAEVaikMulNHSQf7WEyfLRrqyU4DluObwmXy09tVPsk4u9kOi3qRY50kmcT7NQUpWDcRSO3p6jiL1o1byEcJK/VxZkW1gCLIMBRZE/vv+J5+yItRULhpYjiwbsmhMGFtAMO2hg+pXUK6JF+CeEj++NPHTlRWCHoJItNoe0CBEy4dx6lGsJ5A7SAqkSli26tEDOX5M7ZOfh7MHE1VPc6OPDSI9xh3NCeOS1aqLZqppKKjsfhh2ZHvgL1rj6w== root@sythe"
  ];

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  system.stateVersion = "18.09";
}

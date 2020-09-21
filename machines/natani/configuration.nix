# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/machines/${config.networking.hostName}/nixpkgs"
    "nixos-config=/etc/nixos/machines/${config.networking.hostName}/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../../profiles/common.nix
    ../../profiles/work.nix
    ../../modules
    #./profiles/hardened.nix
  ];

  #talyz.gnome.enable = true;
  talyz.exwm.enable = true;

  hardware = {
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
  };

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # Make /tmp a tmpfs mount.
    #tmpOnTmpfs = true;
    kernelPackages = pkgs.linuxPackages_latest_hardened;
    extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    kernelModules = [ "kvm-intel" ];
  };

  networking.hostName = "natani";

  # Make suspend to ram work.
  services.udev.extraRules =
  ''
    #ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control" ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="xhci_hcd", TEST=="power/wakeup" ATTR{power/wakeup}="disabled"
  '';


  # Video drivers
  services.xserver.videoDrivers = [ "intel" ];
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel ];
  services.xserver.deviceSection = ''
    Option        "Tearfree"      "true"
  '';

  
  # Touchpad

  # Workaround for a bug where multitouch stops working after suspend
  # and resume.
  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  services.xserver.libinput.accelSpeed = "0.3";

  # TrackPoint
  services.xserver.inputClassSections = [
    ''
      Identifier     "TrackPoint configuration"
      MatchProduct   "TrackPoint"
      Option "AccelSpeed" "0.4"
    ''
  ];

  # Powersaving and battery charge control
  services.tlp = {
    enable = true;
    extraConfig =
      ''
        ENERGY_PERF_POLICY_ON_AC=performance
        ENERGY_PERF_POLICY_ON_BAT=balance-power
        CPU_SCALING_GOVERNOR_ON_AC=performance
        CPU_SCALING_GOVERNOR_ON_BAT=powersave
        USB_AUTOSUSPEND=0
        RUNTIME_PM_ON_BAT=on
        START_CHARGE_THRESH_BAT0=90
        STOP_CHARGE_THRESH_BAT0=100
      '';
  };

  boot.initrd.luks.devices."nixroot".device = "/dev/disk/by-uuid/527439dc-2e4f-4f1c-80e6-868178da99a8";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/aa5aed15-618a-4246-99e7-d764388d61f6";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };
    
    "/nix" = {
      device = "/dev/disk/by-uuid/aa5aed15-618a-4246-99e7-d764388d61f6";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };
    
    "/home" = {
      device = "/dev/disk/by-uuid/aa5aed15-618a-4246-99e7-d764388d61f6";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };
    
    "/boot" = {
      device = "/dev/disk/by-uuid/920A-2CF3";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      device = "/dev/sda2";
      randomEncryption = {
        enable = true;
        cipher = "aes-xts-plain64";
      };
    }
  ];

  nix.maxJobs = lib.mkDefault 4;
  
  # Enable firewall
  networking.firewall = {
    enable = true;
    allowPing = true;
  # Open ports in the firewall.
  # allowedTCPPorts = [ ... ];
  # allowedUDPPorts = [ ... ];
  };

  # Enable automatic screen rotation.
  hardware.sensor.iio.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}

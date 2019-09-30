# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/machines/flora/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];
  
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../../profiles/common.nix
    ../../profiles/work.nix
    ../../modules
    # ./profiles/hardened.nix
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
    # extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "nvme" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
  };

  networking.hostName = "flora";

  # Video drivers
  services.xserver.videoDrivers = [ "intel" ];
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel ];
  services.xserver.deviceSection = ''
    Option        "Tearfree"      "true"
  '';

  # Touchpad
  services.xserver.libinput.accelSpeed = "0.3";

  # TrackPoint
  services.xserver.inputClassSections = [
    ''
      Identifier     "TrackPoint configuration"
      MatchProduct   "TrackPoint"
      Option "AccelSpeed" "0.6"
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
        START_CHARGE_THRESH_BAT0=75
        STOP_CHARGE_THRESH_BAT0=80
      '';
  };

  environment.persistence = {

    targetDir = "/persistent";

    root = {
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
      ];
    };

    etc = {
      directories = [ "NetworkManager/system-connections" ];
      files = [ "machine-id" ];
    };

  };
  
  users.mutableUsers = false;
  users.users.talyz.passwordFile = "/persistent/password_talyz";
  users.users.root.passwordFile = "/persistent/password_root";

  boot.initrd.luks.devices."nixroot".device = "/dev/disk/by-uuid/d4663e0d-c010-41c9-9f9b-cd1e86e38361";

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=75%" "mode=755" ];
  };

  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/240881f5-782f-4d6a-8dd8-fd4151f33a78";
  #   fsType = "btrfs";
  #   options = [ ];
  # };

  fileSystems."/persistent" = {
    device = "/dev/disk/by-uuid/4fe8590d-920f-4811-96d5-ce8e560f116d";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=persistent" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/4fe8590d-920f-4811-96d5-ce8e560f116d";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/etc/nixos" = {
    device = "/persistent/etc/nixos";
    options = [ "bind" "noauto" "x-systemd.automount" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/194B-06B7";
    fsType = "vfat";
  };

  # fileSystems."/root" = {
  #   device = "/persistent/root";
  #   options = [ "bind" "noauto" "x-systemd.automount" ];
  # };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/aae52a21-ce44-4826-b8a9-5ba71f0caad3"; }
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
  system.stateVersion = "19.09"; # Did you read the comment?
}

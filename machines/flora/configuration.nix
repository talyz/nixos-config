{ config, lib, pkgs, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/machines/flora/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../../modules
  ];

  talyz.gnome.enable = true;
  talyz.gnome.privateDconfSettings."/persistent/home/talyz/gsconnect_settings" = "/org/gnome/shell/extensions/";

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
    kernelPackages = pkgs.linuxPackages_latest;
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
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
      INTEL_GPU_MIN_FREQ_ON_AC = 900;
      INTEL_GPU_MIN_FREQ_ON_BAT = 600;
      INTEL_GPU_MAX_FREQ_ON_AC = 900;
      INTEL_GPU_MAX_FREQ_ON_BAT = 900;
      INTEL_GPU_BOOST_FREQ_ON_AC = 900;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 900;
      USB_AUTOSUSPEND = 0;
      RUNTIME_PM_ON_BAT = "on";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  talyz.ephemeralRoot.enable = true;
  talyz.ephemeralRoot.root.extraFiles = [
    "/etc/nix/id_rsa"
  ];

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

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/194B-06B7";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/dev/disk/by-uuid/aae52a21-ce44-4826-b8a9-5ba71f0caad3";
  }];

  nix.maxJobs = lib.mkDefault 2;

  nix.buildMachines = [{
    hostName = "zen";
    sshUser = "root";
    system = "x86_64-linux";
    maxJobs = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  }];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
  nix.binaryCaches = lib.mkAfter [ "ssh-ng://zen" ];
  nix.binaryCachePublicKeys = lib.mkAfter [ "zen:/mViKdKKlduW1kwAGKauOPM0dg3Jfe6Z4Yosho+54PU=" ];

  programs.ssh.knownHosts.zen = {
    hostNames = [ "zen" "10.0.15.50" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyFlaKS43N8ZqheVodC2g1Xo0Z/HvvI+aekYHw9bIIS";
  };
  programs.ssh.extraConfig = ''
    Host zen
        Hostname 10.0.15.50
        User root
        IdentitiesOnly yes
        IdentityFile /etc/nix/id_rsa
  '';

  # Enable firewall
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

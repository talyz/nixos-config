# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../../profiles/laptop.nix
    #./profiles/hardened.nix
  ];

  hardware = {
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # Make /tmp a tmpfs mount.
    #tmpOnTmpfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  };

  networking.hostName = "natani";

  # Internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "dvorak-sv-a1";
    defaultLocale = "en_US.UTF-8";
  };
  
  time.timeZone = "Europe/Stockholm";

  nixpkgs.config.allowUnfree = true;
  
  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    skype    
  ];

  # Make suspend to ram work.
  services.udev.extraRules =
  ''
    #ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control" ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="xhci_hcd", TEST=="power/wakeup" ATTR{power/wakeup}="disabled"
  '';

  services.udev.extraHwdb =
  ''
    libinput:name:*TrackPoint*                                                      
     LIBINPUT_ATTR_TRACKPOINT_RANGE=10
  '';

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.talyz = {
    isNormalUser = true;
		extraGroups = [ "wheel" ];
		shell = pkgs.fish;
		uid = 1000;
		initialPassword = "aoeuaoeu";
	};

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}

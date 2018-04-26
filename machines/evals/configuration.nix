# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../../profiles/laptop.nix
  ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/2c35e11d-fc79-4fa1-a38c-7cc8e0ac7275";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/81258a07-c9b1-4463-9f60-5979fda9948e";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/81258a07-c9b1-4463-9f60-5979fda9948e";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/28B2-C132";
      fsType = "vfat";
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
  #powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  networking.hostName = "evals";

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

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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
  system.stateVersion = "18.03"; # Did you read the comment?

}

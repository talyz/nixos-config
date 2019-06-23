{ config, pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    liberation_ttf
    source-code-pro
    inconsolata
    dejavu_fonts
    emacs-all-the-icons-fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
  ];

  # fonts.fontconfig.antialias = false;

  environment.systemPackages = with pkgs; [
    firefox-bin
    keepassxc
    dropbox
    freecad
    mpv
    gparted
    gnome3.gnome-keyring
    gnome3.gnome-terminal
    gnome3.evolution
    networkmanagerapplet
  ];

  # Enable pulse with all the bluetooth codec modules.
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];

    daemon.config = {
      flat-volumes = "no";
      default-sample-format = "s24le";
      default-sample-rate = "44100";
      resample-method = "speex-float-10";
      avoid-resampling = "true";
    };

    package = pkgs.pulseaudioFull;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Don't have xterm as a session manager.
  services.xserver.desktopManager.xterm.enable = false;

  # Use libinput to handle trackpoint, touchpad, etc.
  services.xserver.libinput.enable = true;

  # Keyboard layout.
  services.xserver.layout = "se";
  services.xserver.xkbOptions = "eurosign:e,ctrl:nocaps,numpad:mac,kpdl:dot";
  services.xserver.xkbVariant = "dvorak";

  # Enable networkmanager.
  networking.networkmanager.enable = true;
  users.extraUsers.talyz.extraGroups = [ "networkmanager" ];

  services.avahi.enable = true;
  services.avahi.browseDomains = [ "internal.xlnaudio.com" ];

  services.gnome3.gnome-keyring.enable = true;
  services.gnome3.gnome-online-accounts.enable = true;
  services.gnome3.evolution-data-server.enable = true;
  security.polkit.enable = true;
  services.udisks2.enable = true;
  services.accounts-daemon.enable = true;
  services.gnome3.gnome-terminal-server.enable = true;
  programs.dconf.enable = true;
  
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # Enable the smartcard deamon.
  services.pcscd.enable = true;
}

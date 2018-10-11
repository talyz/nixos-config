{ config, pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    liberation_ttf
    source-code-pro
    inconsolata
    dejavu_fonts
    emacs-all-the-icons-fonts
  ];

  environment.systemPackages = with pkgs; [
    firefox-bin
    keepassxc
    dropbox
    freecad
    kdenlive
    ffmpeg
    frei0r
    breeze-icons
    mpv
    gparted
  ];

  # Disable the insane trackpoint averaging and clipping; also, make
  # the acceleration curve less extreme to avoid excessive jumpiness.
  nixpkgs.config.packageOverrides = pkgs: {
    libinput = pkgs.libinput.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches ++ [
        ./libinput_patches/libinput_disable_trackpoint_averaging.patch
        ./libinput_patches/libinput_disable_trackpoint_max_delta_clipping.patch
        ./libinput_patches/libinput_disable_trackpoint_max_accel_clipping.patch
        ./libinput_patches/libinput_trackpoint_sqrt_delta.patch
      ];
    });
  };

  # Enable pulseaudio.
  hardware.pulseaudio.enable = true;

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

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # Enable the smartcard deamon.
  services.pcscd.enable = true;
}

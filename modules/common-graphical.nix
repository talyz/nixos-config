{ config, pkgs, lib, ... }:

let
  cfg = config.talyz.common-graphical;
in
{
  options = {
    talyz.common-graphical.enable = lib.mkOption {
      default = false;
      example = true;
      description = ''
        Whether to enable common graphical environment settings.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    fonts.fonts = with pkgs; [
      liberation_ttf
      source-code-pro
      inconsolata
      dejavu_fonts
      #emacs-all-the-icons-fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
      fira-code
      fira-code-symbols
    ];

    # fonts.fontconfig.antialias = false;

    environment.systemPackages = with pkgs; [
      firefox
      (keepassxc.override { withKeePassNetworking = true; })
      dropbox
      freecad
      krita
      mpv
      kitty
      gparted
      gnome3.evolution
      gnome3.evince
      gnome3.adwaita-icon-theme
      google-play-music-desktop-player
      google-musicmanager
      aspell
      aspellDicts.sv
      aspellDicts.en
      aspellDicts.en-science
      aspellDicts.en-computers
    ];

    xdg.icons.enable = true;

    # Enable pulse with all the bluetooth codec modules.
    hardware.pulseaudio = {
      enable = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];

      daemon.config = {
        flat-volumes = "no";
        default-sample-format = "s24le";
        # default-sample-rate = "44100";
        # resample-method = "speex-float-5";
        # avoid-resampling = "true";
      };

      configFile = pkgs.runCommand "default.pa" {} ''
        sed 's/load-module module-bluetooth-discover/load-module module-bluetooth-discover a2dp_config="aac_afterburner=on aac_bitrate_mode=0"/' \
          ${pkgs.pulseaudioFull}/etc/pulse/default.pa > $out
      '';

      package = pkgs.pulseaudioFull;
    };

    hardware.opengl.enable = true;
    hardware.opengl.s3tcSupport = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Don't have xterm as a session manager.
    services.xserver.desktopManager.xterm.enable = false;

    # Use libinput to handle trackpoint, touchpad, etc.
    services.xserver.libinput.enable = true;
    services.xserver.libinput.naturalScrolling = true;

    # Keyboard layout.
    services.xserver.layout = "se";
    services.xserver.xkbOptions = "eurosign:e,ctrl:nocaps,numpad:mac,kpdl:dot";
    services.xserver.xkbVariant = "dvorak";

    # Enable networkmanager.
    networking.networkmanager.enable = true;

    services.avahi.enable = true;
    services.avahi.browseDomains = [ "internal.xlnaudio.com" ];

    # Enable wireshark.
    programs.wireshark.enable = true;
    programs.wireshark.package = pkgs.wireshark-qt;

    programs.gnome-terminal.enable = true;
    services.gnome3.gnome-keyring.enable = true;
    #security.pam.services.login.enableGnomeKeyring = true;
    security.pam.services.lightdm.enableGnomeKeyring = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    services.gnome3.gnome-online-accounts.enable = true;
    services.gnome3.evolution-data-server.enable = true;
    security.polkit.enable = true;
    services.udisks2.enable = true;
    services.accounts-daemon.enable = true;
    programs.dconf.enable = true;
    services.upower.enable = true;

    services.xserver.displayManager.gdm = {
      enable = true;
      #autoLogin.enable = true;
      autoLogin.user = "talyz";
    };

    #gtk.iconCache.enable = true;

    programs.adb.enable = true;
    #android_sdk.accept_license = true;

    # Enable CUPS to print documents.
    services.printing = {
      enable = true;
      drivers = [
        pkgs.hplipWithPlugin
        pkgs.postscript-lexmark
      ];
    };

    # Enable printer configuration
    #hardware.printers.ensureDefaultPrinter = "Lexmark_CS510de";
    hardware.printers.ensurePrinters = [
      {
        name = "Lexmark_CS510de";
        deviceUri = "ipps://192.168.0.124:443/ipp/print";
        model = "postscript-lexmark/Lexmark-CS510_Series-Postscript-Lexmark.ppd";
        location = "UFS";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];

    # Enable SANE to scan documents.
    services.saned.enable = true;
    hardware.sane.enable = true;
    hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];
    hardware.sane.netConf = "printer.internal.xlnaudio.com";

    # Enable the smartcard deamon.
    services.pcscd.enable = true;

    users.users.talyz.extraGroups = [ "networkmanager" "video" "adbusers" "lp" "scanner" "wireshark" ];

  };
}

{ config, pkgs, lib, ... }:

let
  cfg = config.talyz.common-graphical;
  user = config.talyz.username;
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
      noto-fonts
      noto-fonts-emoji
      noto-fonts-extra
      fira-code
      fira-code-symbols
      iosevka
    ];

    # fonts.fontconfig.antialias = false;

    environment.systemPackages = with pkgs; [
      firefox-wayland
      keepassxc
      dropbox
      krita
      mpv
      discord
      gparted
      evolution
      gnome3.evince
      gnome3.adwaita-icon-theme
      aspell
      aspellDicts.sv
      aspellDicts.en
      aspellDicts.en-science
      aspellDicts.en-computers
      foot
    ];

    environment.sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
    };

    xdg.icons.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      # jack.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      media-session.config.bluez-monitor = {
        properties = {
          "bluez5.sbc-xq-support" = true;
          "bluez5.headset-roles" = [
            # "hsp_hs"
            # "hsp_ag"
            "hfp_hf"
            "hfp_ag"
          ];
        };

        rules = [{
          matches = [{
            # This matches all cards.
            "device.name" = "~bluez_card.*";
          }];
          actions.update-props."bluez5.msbc-support" = true;
        }];
      };
    };

    hardware.pulseaudio.enable = false;

    hardware.opengl.enable = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Don't have xterm as a session manager.
    services.xserver.desktopManager.xterm.enable = false;

    # Use libinput to handle trackpoint, touchpad, etc.
    services.xserver.libinput.enable = true;
    services.xserver.libinput.touchpad.naturalScrolling = true;

    # Keyboard layout.
    services.xserver.layout = "us";
    services.xserver.xkbOptions = "eurosign:e,ctrl:nocaps,numpad:mac,kpdl:dot";
    services.xserver.xkbVariant = "dvorak-intl";

    # Enable Flatpak.
    services.flatpak.enable = true;

    # Enable networkmanager.
    networking.networkmanager.enable = lib.mkDefault true;

    services.avahi.enable = true;

    # Enable wireshark.
    programs.wireshark.enable = true;
    programs.wireshark.package = pkgs.wireshark-qt;

    programs.gnome-terminal.enable = true;
    services.gnome.gnome-keyring.enable = true;
    #security.pam.services.login.enableGnomeKeyring = true;
    security.pam.services.lightdm.enableGnomeKeyring = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    services.gnome.gnome-online-accounts.enable = true;
    services.gnome.evolution-data-server.enable = true;
    security.polkit.enable = true;
    services.udisks2.enable = true;
    services.accounts-daemon.enable = true;
    programs.dconf.enable = true;
    services.upower.enable = true;

    services.xserver.displayManager.gdm = {
      enable = true;
      #autoLogin.enable = true;
      #autoLogin.user = ${user};
    };

    #gtk.iconCache.enable = true;

    home-manager.users.${user} = { lib, ... }:
      {
        gtk.enable = true;
        gtk.iconTheme = {
          package = pkgs.gnome3.adwaita-icon-theme;
          name = "Adwaita";
        };
        gtk.gtk3.extraConfig = {
          gtk-cursor-theme-name = "Adwaita";
          gtk-application-prefer-dark-theme = 1;
        };

        # xdg.mimeApps.enable = true;
        # xdg.mimeApps.defaultApplications = {
        #   "application/pdf" = [ "org.gnome.Evince.desktop" ];
        #   "image/pdf" = [ "org.gnome.Evince.desktop" ];
        # };

        services.dunst.enable = true;
        services.dunst.iconTheme = {
          package = pkgs.gnome3.adwaita-icon-theme;
          name = "Adwaita";
        };
        services.dunst.settings =  {
          global = {
            geometry = "500x5-30+50";
            padding = 8;
            horizontal_padding = 8;
            frame_color = "#eceff1";
            font = "Droid Sans 11";
          };

          urgency_normal = {
            background = "#37474f";
            foreground = "#eceff1";
            timeout = 10;
          };
        };

        programs.mpv.enable = true;
        programs.mpv.config = {
          profile = "gpu-hq";
          interpolation = true;
          tscale = "oversample";
          video-sync = "display-resample";
        };

        dconf.settings = {
          # Evolution
          "org/gnome/evolution/mail" = {
            forward-style-name = "inline";
            forward-style = 1;
            layout = 1;
          };
        };

        xresources.properties = {
          "XTerm*faceName" = "dejavu sans mono:size=10";
          "XTerm*charClass" = [ "37:48" "45-47:48" "58:48" "64:48" "126:48" ];
          "XTerm.termName" = "xterm-256color";
          "XTerm.vt100.metaSendsEscape" = true;
          "XTerm.vt100.backarrowKey" = false;
          "XTerm.ttyModes" = "erase ^?";
          "XTerm.vt100.saveLines" = "32768";
          "XTerm.vt100.reverseVideo" = true;
          "xterm*VT100.Translations" = ''#override \
            Ctrl Shift <Key>V:    insert-selection(CLIPBOARD) \n\
            Ctrl Shift <Key>C:    copy-selection(CLIPBOARD)
          '';
        };

        programs.foot = {
          enable = true;
          settings = {
            main = {
              font = "monospace:size=10";
              dpi-aware = "no";
            };
            colors = {
              alpha = 1.0;
              foreground = "c5c8c6";
              background = "000000";
              regular0 = "000000";  # black
              regular1 = "cc2222";  # red
              regular2 = "22cc22";  # green
              regular3 = "cccc22";  # yellow
              regular4 = "2222cc";  # blue
              regular5 = "cc22cc";  # magenta
              regular6 = "22cccc";  # cyan
              regular7 = "cccccc";  # white
              bright0 = "222222";   # bright black
              bright1 = "ff4444";   # bright red
              bright2 = "44ff44";   # bright green
              bright3 = "ffff44";   # bright yellow
              bright4 = "4444ff";   # bright blue
              bright5 = "ff44ff";   # bright magenta
              bright6 = "44ffff";   # bright cyan
              bright7 = "ffffff";   # bright white
            };
          };
        };

        home.file = {
          ".config/Dharkael/flameshot.ini".text = ''
            [General]
            disabledTrayIcon=true
            drawColor=#ff0000
            drawThickness=0
          '';

          ".config/kitty/kitty.conf".text = ''
            font_family       Fira Code Retina
            bold_font         Fira Code Bold
            italic_font       Fira Code Italic
            bold_italic_font  Fira Code Bold Italic
            font_size         11.0
            repaint_delay     1
            input_delay       1
            term              kitty
          '';
        };
      };

    programs.adb.enable = true;
    #android_sdk.accept_license = true;

    # Enable the smartcard deamon.
    services.pcscd.enable = true;

    users.users.${user}.extraGroups = [
      "networkmanager"
      "video"
      "adbusers"
      "wireshark"
    ];

  };
}

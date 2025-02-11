{ config, lib, pkgs, isStable, ... }:

with lib;

let
  cfg = config.talyz.gnome;
  user = config.talyz.username;
in
{
  options =
    {
      talyz.gnome =
        {
          enable = mkOption {
            default = false;
            example = true;
            description = "Whether to enable the gnome desktop.";
            type = types.bool;
          };
          useWayland = mkOption {
            default = true;
            description = ''
              Set appropriate options for the Wayland session.
            '';
          };
          privateDconfSettings = mkOption {
            default = null;
            example = { "/persistent/home/${user}/gsconnect_settings" = "/org/gnome/shell/extensions/"; };
            description = ''
              External files to import dconf settings from. The
              attribute name is the path to the file to read settings
              from, its value is the dconf path under which the
              settings should be loaded.
            '';
            type = types.nullOr (types.attrsOf types.str);
          };
        };
    };

  config = mkIf cfg.enable
  {
    environment.systemPackages = with pkgs;
    [
      evince
      pavucontrol
      glib.dev
      gnomeExtensions.gsconnect
      gnomeExtensions.appindicator
      rhythmbox
      gnome-tweaks
    ];

    environment.sessionVariables = lib.optionalAttrs cfg.useWayland {
      QT_QPA_PLATFORM = "wayland";
      NIXOS_OZONE_WL = "1";
      # MUTTER_DEBUG_FORCE_KMS_MODE = "simple";
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome.gnome-software
    ];
    services.packagekit.enable = lib.mkForce false;

    # Open firewall port for GSConnect
    networking.firewall.allowedTCPPorts = [ 1716 ];

    # Link the GSConnect config to persistent storage
    talyz.ephemeralRoot.home.extraDirectories = [
      ".config/gsconnect"
    ];

    talyz.common-graphical.enable = true;

    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.wayland = cfg.useWayland;
    security.rtkit.enable = true; # To make rt-scheduler work

    systemd.services.accounts-daemon.restartIfChanged = false;

    services.fwupd.enable = true;

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    home-manager.users.${user} = { lib, ... }:
      {
        xdg.configFile."gnome-initial-setup-done".text = "yes";

        dconf.settings =
          {
            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = [
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
              ];
            };

            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
              name = "terminal";
              binding = "<Super>c";
              command = if cfg.useWayland then "foot" else "xterm";
            };

            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
              name = "emacsclient";
              binding = "<Super>e";
              command = "emacs";
            };

            "org/gnome/desktop/input-sources" = {
              sources = [
                (lib.hm.gvariant.mkTuple [ "xkb" "us+dvorak-intl" ])
              ] ++ lib.optional config.talyz.media-center.enable
                (lib.hm.gvariant.mkTuple [ "xkb" "se" ]);
              xkb-options = [ "eurosign:e" "ctrl:nocaps" "numpad:mac" "kpdl:dot" ];
            };

            "org/gnome/desktop/wm/keybindings" = {
              switch-to-workspace-1 = [ "<Super>1" ];
              switch-to-workspace-2 = [ "<Super>2" ];
              switch-to-workspace-3 = [ "<Super>3" ];
              switch-to-workspace-4 = [ "<Super>4" ];
              switch-to-workspace-5 = [ "<Super>5" ];
              switch-to-workspace-6 = [ "<Super>6" ];
              switch-to-workspace-7 = [ "<Super>7" ];
              switch-to-workspace-8 = [ "<Super>8" ];
              switch-to-workspace-9 = [ "<Super>9" ];
              switch-windows = [ "<Alt>Tab" ];
              switch-applications = [];
            };

            "org/gnome/shell/keybindings" = {
              switch-to-application-1 = [];
              switch-to-application-2 = [];
              switch-to-application-3 = [];
              switch-to-application-4 = [];
              switch-to-application-5 = [];
              switch-to-application-6 = [];
              switch-to-application-7 = [];
              switch-to-application-8 = [];
              switch-to-application-9 = [];
            };

            "org/gnome/desktop/wm/preferences" = {
              num-workspaces = 9;
              resize-with-right-button = true;
            };

            "org/gnome/shell/overrides" = {
              dynamic-workspaces = false;
            };

            "org/gnome/mutter" = {
              dynamic-workspaces = false;
              workspaces-only-on-primary = true;
              experimental-features = [
                "scale-monitor-framebuffer"
              ];
            };

            "org/gnome/desktop/sound" = {
              allow-volume-above-100-percent = !config.talyz.media-center.enable;
              event-sounds = false;
            };

            "org/gnome/shell" = {
              always-show-log-out = true;
            };

            "org/gnome/shell/app-switcher" = {
              current-workspace-only = true;
            };

            "org/gnome/settings-daemon/plugins/power" = {
              idle-dim = config.talyz.media-center.enable;
              sleep-inactive-ac-type = "nothing";
              sleep-inactive-battery-type = "nothing";
            };

            "org/gnome/settings-daemon/plugins/color" = {
              night-light-enabled = true;
            };

            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
            };

            "org/gnome/desktop/background" = {
              picture-options = "zoom";
              picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
              picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
              primary-color = "#241f31";
              secondary-color = "#000000";
            };

            "org/gnome/desktop/session" =
              let
                delay = if config.talyz.media-center.enable then 900 else 0;
              in {
                idle-delay = lib.hm.gvariant.mkUint32 delay;
              };

            "org/gnome/shell" = {
              enabled-extensions = [
                "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
                "gsconnect@andyholmes.github.io"
                "appindicatorsupport@rgcjonas.gmail.com"
              ];
            };

            # File browser (nautilus) settings
            "org/gnome/nautilus/settings" = {
              confirm-trash = false;
              default-folder-viewer = "list-view";
              default-sort-order = "type";
              show-create-link = true;
            };
            "org/gnome/nautilus/list-view" = {
              use-tree-view = true;
            };

            "org/gtk/Settings/FileChooser" = {
              sort-directories-first = true;
              sort-column = "type";
            };

            "org/gnome/evolution/shell/window" = {
              maximized = true;
            };
          };

        home.activation.${if (cfg.privateDconfSettings != null) then "privateDconfSettings" else null} =
          lib.hm.dag.entryAfter ["dconfSettings"] ''
            if [[ -v DBUS_SESSION_BUS_ADDRESS ]]; then
              DCONF_DBUS_RUN_SESSION=""
            else
              DCONF_DBUS_RUN_SESSION="${pkgs.dbus}/bin/dbus-run-session"
            fi

            ${lib.concatMapStringsSep "\n"
              (path: ''
                if [[ -v DRY_RUN ]]; then
                  echo $DCONF_DBUS_RUN_SESSION ${pkgs.dconf}/bin/dconf load ${cfg.privateDconfSettings.${path}} "<" ${path}
                else
                  $DCONF_DBUS_RUN_SESSION ${pkgs.dconf}/bin/dconf load ${cfg.privateDconfSettings.${path}} < ${path}
                fi
              '')
              (lib.attrNames cfg.privateDconfSettings)}

            unset DCONF_DBUS_RUN_SESSION
          '';
      };
  };
}

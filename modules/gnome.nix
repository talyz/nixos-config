{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.gnome;
in
{
  imports = [ ./dconf.nix ];

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
        };
    };

  config = mkIf cfg.enable
  {
    environment.systemPackages = with pkgs;
    [
      evince
      pavucontrol
      glib.dev
      gnome3.gnome-tweak-tool
      gnome3.gnome_session
      gnomeExtensions.dash-to-dock
      gnomeExtensions.topicons-plus
      gnome3.rhythmbox
    ];

    talyz.common-graphical.enable = true;

    services.xserver =
      {
        desktopManager.gnome3 =
          {
            extraGSettingsOverridePackages = with pkgs; [
              gnome3.gnome_shell
            ];

            extraGSettingsOverrides =
              ''
                [org.gnome.desktop.input-sources]
                sources=[('xkb', 'se+dvorak')]
                xkb-options=['eurosign:e', 'ctrl:nocaps', 'numpad:mac', 'kpdl:dot']

                [org.gnome.desktop.wm.keybindings]
                switch-to-workspace-1=['<Super>1']
                switch-to-workspace-2=['<Super>2']
                switch-to-workspace-3=['<Super>3']
                switch-to-workspace-4=['<Super>4']
                switch-to-workspace-5=['<Super>5']
                switch-to-workspace-6=['<Super>6']
                switch-to-workspace-7=['<Super>7']
                switch-to-workspace-8=['<Super>8']
                switch-windows=['<Alt>Tab']
                switch-applications=[]

                [org.gnome.shell.keybindings]
                switch-to-application-1=[]
                switch-to-application-2=[]
                switch-to-application-3=[]
                switch-to-application-4=[]
                switch-to-application-5=[]
                switch-to-application-6=[]
                switch-to-application-7=[]
                switch-to-application-8=[]
                switch-to-application-9=[]

                [org.gnome.desktop.wm.preferences]
                num-workspaces=8

                [org.gnome.shell.overrides]
                dynamic-workspaces=false

                [org.gnome.desktop.wm.preferences]
                resize-with-right-button=true

                [org.gnome.shell]
                always-show-log-out=true

                [org.gnome.shell.app-switcher]
                current-workspace-only=true

                [org.gnome.settings-daemon.plugins.power]
                idle-dim=false
                sleep-inactive-ac-type='nothing'
                sleep-inactive-battery-type='nothing'

                [org.gnome.desktop.session]
                idle-delay=0

                [org.gnome.shell]
                enabled-extensions=['TopIcons@phocean.net', 'launch-new-instance@gnome-shell-extensions.gcampax.github.com']
              '';

              # Enable the GNOME 3 Desktop Environment.
              enable = true;
          };
      };

      systemd.services.accounts-daemon.restartIfChanged = false;

      services.fwupd.enable = true;

      talyz.emacs.enable = true;

      # Define custom keybindings.

      # Because of what is most likely a bug in gsettings, parameters
      # using relocatable schema, such as custom keybindings, can't be
      # added using gschema overrides. This means we have to add them
      # directly to a dconf database instead.
      programs.dconfTalyz.enable = true;
      programs.dconfTalyz.defaultOverrides = ''
        [org/gnome/settings-daemon/plugins/media-keys]
        custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
        binding='<Super>c'
        command='gnome-terminal'
        name='terminal'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1]
        binding='<Super>e'
        command='emacsclient -c'
        name='emacsclient'
      '';
  };
}

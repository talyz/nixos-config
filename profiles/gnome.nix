{ config, lib, pkgs, ... }:

with lib;

let
  gse-show-workspaces = pkgs.callPackage ./gse-show-workspaces.nix { };
in
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
    gse-show-workspaces
    aspell
    aspellDicts.sv
    aspellDicts.en
    aspellDicts.en-science
    aspellDicts.en-computers
  ];
  
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
        enabled-extensions=['TopIcons@phocean.net', 'launch-new-instance@gnome-shell-extensions.gcampax.github.com', 'alternate-tab@gnome-shell-extensions.gcampax.github.com', 'gse-show-workspaces@ns.petersimonyi.ca']
      '';

      # Enable the GNOME 3 Desktop Environment.
      enable = true;
    };
    
    displayManager.gdm =
    {
      enable = true;
      autoLogin.enable = true;
      autoLogin.user = "talyz";
    };
  };

  systemd.services.accounts-daemon.restartIfChanged = false;
  
  services.fwupd.enable = true;
  
  # Define custom keybindings.

  # Because of what is most likely a bug in gsettings, parameters
  # using relocatable schema, such as custom keybindings, can't be
  # added using gschema overrides. This means we have to add them
  # directly to a dconf database instead.
  environment.etc =
  {
    "dconf/db/system-wide.d/00_custom_keybindings".text =
    ''
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

  "dconf/profile/user".text =
    ''
      user-db:user
      system-db:system-wide
    '';
  };

#  programs.dconf.profiles.gnome_conf = "/etc/nix/gnome_dconf";
}

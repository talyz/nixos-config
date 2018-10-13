{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dconfTalyz;

  mkDconfProfile = name: path: {
    source = path;
    target = "dconf/profile/${name}";
  };

  defaultOverrides =
    if (cfg.defaultOverrides != null) then
      (pkgs.runCommand "system-wide.dconf" {
        buildInputs = [ pkgs.gnome3.dconf ];
        passAsFile = [ "defaultOverrides" ];
        defaultOverrides = cfg.defaultOverrides;
      } ''
        mkdir system-wide.d
        if [[ -e "$defaultOverridesPath" ]]; then
          mv "$defaultOverridesPath" "system-wide.d/00-custom"
        else
          echo -n "$defaultOverrides" > "system-wide.d/00-custom"
        fi
        dconf compile $out system-wide.d/
      '')
    else
      null;
in
{
  options = {
    programs.dconfTalyz = {
      enable = mkEnableOption "dconf";

      profiles = mkOption {
        type = types.attrsOf types.path;
        default = {};
        description = "Set of dconf profile files.";
        internal = true;
      };

      defaultOverrides = mkOption {
        type = types.nullOr types.lines;
        default = null;
        example = mkLiteralExample ''
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
        description = ''
          Override system-wide default settings for dconf programs (i.e. gnome et al.)
          This can be used as an alternative to extraGSettingsOverrides and enables
          setting parameters with relocatable schema (such as custom keybindings in
          gnome.)
        '';
      };
    };
  };

  ###### implementation

  config = mkIf (cfg.profiles != {} || cfg.defaultOverrides != null || cfg.enable) {
    environment.etc = optionals (cfg.profiles != {})
      (mapAttrsToList mkDconfProfile cfg.profiles) ++
      optional (cfg.defaultOverrides != null) {
        target = "dconf/profile/user";
        text = ''
          user-db:user
          file-db:${defaultOverrides}
        '';
      };

    environment.variables.GIO_EXTRA_MODULES = optional cfg.enable
      "${pkgs.gnome3.dconf.lib}/lib/gio/modules";
    # https://github.com/NixOS/nixpkgs/pull/31891
    #environment.variables.XDG_DATA_DIRS = optional cfg.enable
    #  "$(echo ${pkgs.gnome3.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-*)";
  };

}

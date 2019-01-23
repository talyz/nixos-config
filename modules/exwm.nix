{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.exwm;
  loadScript = ./exwm.el;
in
{
  options =
  {
    talyz.exwm = {
      enable = mkOption {
        default = false;
        example = true;
        description = "Whether to enable the exwm window manager.";
        type = types.bool;
      };
      lockerCommand = mkOption {
        default = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
      };
    };
  };
  config =
    mkIf cfg.enable (mkMerge [
      ((import ../profiles/common-graphical.nix) { inherit config pkgs; })
      {
        nixpkgs.overlays =
          [
            (import
              (builtins.fetchTarball
                {
                  url = https://github.com/adisbladis/exwm-overlay/archive/master.tar.gz;
                }))
          ];
        # services.dunst.enable = true;

        programs.light.enable = true;

        talyz.emacs.enable = true;
        talyz.emacs.extraPackages = [ "desktop-environment" "exwm" ];

        environment.systemPackages = with pkgs; [
          flameshot
        ];

        services.xserver.windowManager.session = singleton {
          name = "exwm";
          start = ''
            ${pkgs.compton}/bin/compton --backend glx &
            nm-applet &
            ${pkgs.xss-lock}/bin/xss-lock -- ${cfg.lockerCommand} &
            ${pkgs.emacs}/bin/emacs -l ${loadScript}
          '';
        };
      }
    ]);
}

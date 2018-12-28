{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.laptop;
in
{
  options =
    {
      talyz.laptop =
        {
          tlp.enable =  mkOption {
            default = false;
            example = true;
            description = "Whether to use tlp to extend battery life.";
            type = types.bool;
          };
        };
    };
  config = 
    lib.mkIf cfg.tlp.enable {
      services.tlp = {
        enable = true;
        extraConfig =
          ''
            CPU_HWP_ON_AC=performance
            USB_AUTOSUSPEND=0
            START_CHARGE_THRESH_BAT0=75
            STOP_CHARGE_THRESH_BAT0=80
            RUNTIME_PM_ON_BAT=on
          '';
      };
    };
}

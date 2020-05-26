{ config, pkgs, lib, ... }:

let
  cfg = config.talyz.media-center;
in
{
  options = {
    talyz.media-center.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      example = true;
      description = ''
        Whether this machine is used as a Media Center.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kodi
    ];

    services.nzbget.enable = true;

    services.sonarr.enable = true;
    services.sonarr.dataDir = "/var/lib/sonarr";
    services.sonarr.openFirewall = true;

    services.radarr.enable = true;
    services.radarr.dataDir = "/var/lib/radarr";
    services.radarr.openFirewall = true;
  };
}

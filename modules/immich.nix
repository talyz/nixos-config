{ config, lib, ... }:
let
  cfg = config.talyz.immich;
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
  ;
in
{
  options = {
    talyz.immich.enable = mkOption {
      default = false;
      type = types.bool;
      example = true;
      description = ''
        Whether this machine is used for photo hosting and sharing.
      '';
    };
  };
  config = mkMerge [

    (mkIf cfg.enable
      {
        services.immich.enable = true;
        services.immich.settings = {
          server.externalDomain = "https://photos.at.webhallon.com";
        };
        services.immich.host = "127.0.0.1";
        services.immich.mediaLocation = "/media/raid/immich";
        # services.immich.environment = {
        #   IMMICH_HOST = "127.0.0.1";
        # };

        talyz.backups.paths = [
          config.services.immich.mediaLocation
        ];

        services.nginx = {
          enable = true;

          recommendedTlsSettings = true;
          recommendedOptimisation = true;
          recommendedGzipSettings = true;
          recommendedProxySettings = true;

          upstreams.immich.servers."127.0.0.1:${toString config.services.immich.port}" = {};
          virtualHosts."photos.${config.talyz.domain.internal.domain}" = {
            locations."/".tryFiles = "$uri @immich";
            locations."@immich" = {
              proxyPass = "http://immich";
              proxyWebsockets = true;
            };
            locations."@immich".extraConfig = ''
              client_max_body_size 0;
            '';
            addSSL = true;
            useACMEHost = config.talyz.domain.internal.domain;
          };
        };
        talyz.domain.internal.getCertificate = true;

        environment.persistence.main.directories = [
          { directory = config.services.postgresql.dataDir; mode = "0750"; user = "postgres"; group = "postgres"; }
        ];

        environment.persistence.cache.directories = [
          { directory = "/var/cache/immich"; mode = "0700"; user = "immich"; group = "immich"; }
        ];
      })

    {
      talyz.domain.internal.services = [
        "photos"
      ];
    }

  ];
}

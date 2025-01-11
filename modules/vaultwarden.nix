{ config, pkgs, lib, ... }:

let
  inherit (lib)
    mkOption
    mkMerge
    mkIf
    types;

  cfg = config.talyz.vaultwarden;
in
{
  options.talyz.vaultwarden =
    {
      enable = mkOption {
        default = false;
        example = true;
        description = "Whether to host Vaultwarden.";
        type = types.bool;
      };
    };

  config = mkMerge [
    (mkIf cfg.enable
      {
        services.vaultwarden = {
          enable = true;
          config = {
            ROCKET_ADDRESS = "127.0.0.1";
            ROCKET_PORT = 8000;
            ROCKET_WORKERS = 10;
            SIGNUPS_ALLOWED = false;
            DOMAIN = "https://vaultwarden.${config.talyz.domain.internal.domain}";
            SMTP_HOST = "smtp.gmail.com";
            SMTP_PORT = 465;
            SMTP_SECURITY = "force_tls";
            SMTP_USERNAME = "kim.lindberger@gmail.com";
            SMTP_FROM = "kim.lindberger@gmail.com";
            SMTP_FROM_NAME = "Vaultwarden";
            SMTP_SSL = true;
            SMTP_EXPLICIT_TLS = true;
            PASSWORD_ITERATIONS = 2000000;
          };
          environmentFile = config.sops.secrets.vaultwarden-env.path;
          backupDir = "/var/lib/vaultwarden-backup";
        };

        sops.secrets.vaultwarden-env = {
          restartUnits = [ "vaultwarden.service" ];
        };

        environment.persistence.main.directories = [
          { directory = "/var/lib/bitwarden_rs"; mode = "0700"; user = "vaultwarden"; group = "vaultwarden"; }
          { directory = config.services.vaultwarden.backupDir; mode = "0700"; user = "vaultwarden"; group = "vaultwarden"; }
        ];

        services.nginx = {
          enable = true;

          recommendedTlsSettings = true;
          recommendedOptimisation = true;
          recommendedGzipSettings = true;
          recommendedProxySettings = true;

          upstreams.vaultwarden.servers."127.0.0.1:8000" = {};
          virtualHosts."vaultwarden.${config.talyz.domain.internal.domain}" = {
            locations."/".tryFiles = "$uri @vaultwarden";
            locations."@vaultwarden" = {
              proxyPass = "http://vaultwarden";
              proxyWebsockets = true;
            };
            forceSSL = true;
            useACMEHost = config.talyz.domain.internal.domain;
          };
        };
        talyz.domain.internal.getCertificate = true;

        networking.firewall.allowedTCPPorts = [ 80 443 ];
      })
    {
      talyz.domain.internal.services = [ "vaultwarden" ];
    }
  ];
}

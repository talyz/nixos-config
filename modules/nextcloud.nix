{ config, pkgs, lib, ... }:
let
  cfg = config.talyz.nextcloud;
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
  ;
in
{
  options = {
    talyz.nextcloud.enable = mkOption {
      default = false;
      type = types.bool;
      example = true;
      description = ''
        Whether this machine should host Nextcloud.
      '';
    };
  };
  config = mkMerge [

    (mkIf cfg.enable
      {
        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud30;
          hostName = "nextcloud.${config.talyz.domain.internal.domain}";
          database.createLocally = true;
          configureRedis = true;
          https = true;
          home = "/media/raid/nextcloud";
          config = {
            dbtype = "pgsql";
            adminuser = "admin";
            adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
          };
          settings = {
            maintenance_window_start = 1;
            default_phone_region = "SE";
            mail_smtpmode = "smtp";
            mail_smtphost = "smtp.gmail.com";
            mail_smtpport = 465;
            mail_smtpsecure = "ssl";
            mail_smtpauth = true;
            mail_smtpname = "kim.lindberger@gmail.com";
          };
          secretFile = config.sops.secrets.nextcloud-secrets.path;
          maxUploadSize = "10G";
          extraApps = with config.services.nextcloud.package.packages.apps; {
            inherit calendar contacts mail notes tasks;
          };
          phpOptions = {
            "opcache.interned_strings_buffer" = "64";
            "opcache.memory_consumption" = "256";
            "opcache.jit" = "1255";
            "opcache.jit_buffer_size" = "8M";
            "opcache.validate_timestamps" = "0";
          };
        };

        # services.onlyoffice = {
        #   enable = true;
        #   hostname = "onlyoffice.${config.talyz.domain.internal.domain}";
        #   port = 8002;
        # };

        sops.secrets.nextcloud-admin-password = {
          owner = "nextcloud";
          group = "nextcloud";
        };
        sops.secrets.nextcloud-secrets = {
          owner = "nextcloud";
          group = "nextcloud";
        };

        talyz.backups.paths = [
          config.services.nextcloud.home
        ];

        services.nginx = {
          enable = true;

          recommendedTlsSettings = true;
          recommendedOptimisation = true;
          recommendedGzipSettings = true;
          recommendedProxySettings = true;

          virtualHosts.${config.services.nextcloud.hostName} = {
            addSSL = true;
            useACMEHost = config.talyz.domain.internal.domain;
          };
        };
        talyz.domain.internal.getCertificate = true;

        # environment.persistence.main.directories = [
        #   { directory = config.services.postgresql.dataDir; mode = "0750"; user = "postgres"; group = "postgres"; }
        # ];
      })

    {
      talyz.domain.internal.services = [
        "nextcloud"
        # "onlyoffice"
      ];
    }
  ];
}

{ config, lib, ... }:

let
  inherit (lib)
    mkOption
    mkMerge
    mkIf
    types;

  cfg = config.talyz.domain;
  domain = "vpn.webhallon.com";
in
{
  options.talyz.domain =
    {
      external.updateDynDNS = mkOption {
        default = false;
        example = true;
        description = ''
          Whether to update the main external DNS domain
          record.
        '';
        type = types.bool;
      };
      internal.runControlServer = mkOption {
        default = false;
        example = true;
        description = "Whether to run the Headscale server.";
        type = types.bool;
      };
      internal.services = mkOption {
        default = [ ];
        example = [ "home-assistant" ];
        description = "Services to add DNS records for.";
        type = types.listOf types.str;
      };
      internal.domain = mkOption {
        default = "at.webhallon.com";
        description = "Domain to use for internal services.";
        type = types.str;
      };
      internal.getCertificate = lib.mkOption {
        default = false;
        type = lib.types.bool;
        example = true;
        description = ''
          Whether to request a Let's Encrypt certificate using
          DNS-01.
        '';
      };
    };

  config = mkMerge [
    (mkIf cfg.internal.runControlServer
      {
        services.headscale = {
          enable = true;
          address = "0.0.0.0";
          port = 443;
          settings = {
            server_url = "https://${domain}";
            tls_letsencrypt_hostname = domain;
            logtail.enabled = false;
            dns = {
              base_domain = cfg.internal.domain;
              extra_records =
                map (name: {
                  name = "${name}.${cfg.internal.domain}";
                  type = "A";
                  value = "100.64.0.4";
                })
                  cfg.internal.services;
            };
          };
        };

        environment.systemPackages = [ config.services.headscale.package ];

        networking.firewall.allowedTCPPorts = [
          80    # HTTP
          443   # HTTPS
        ];
      })

    (mkIf cfg.external.updateDynDNS
      {
        ### Dynamic DNS update ###

        services.ddclient = {
          enable = true;
          server = "dyndns.loopia.se";
          domains = [ "webhallon.com" ];
          usev4 = "webv4, webv4=dyndns.loopia.se/checkip, webv4-skip='Current IP Address:'";
          usev6 = "no";
          username = "webhallon.com";
          passwordFile = config.sops.secrets.loopia-password.path;
        };

        systemd.services.ddclient.after = [ "sops-nix.service" ];
        systemd.services.ddclient.wants = [ "sops-nix.service" ];

        sops.secrets.loopia-password = { };
      })

    (mkIf cfg.internal.getCertificate
      {
        security.acme.certs."${cfg.internal.domain}" = {
          domain = "*.${cfg.internal.domain}";
          dnsProvider = "loopia";
          group = "nginx";
          environmentFile = config.sops.secrets.acme-loopia.path;
          dnsPropagationCheck = true;
        };

        environment.persistence.main.directories = [
          { directory = "/var/lib/acme"; mode = "0755"; user = "acme"; group = "acme"; }
        ];

        systemd.services.nginx.after = [ "acme-${cfg.internal.domain}.service" ];
        systemd.services.nginx.wants = [ "acme-${cfg.internal.domain}.service" ];

        sops.secrets.acme-loopia = { };
      })

    {
      security.acme = {
        acceptTerms = true;
        defaults.email = "kim.lindberger@gmail.com";
      };
    }
  ];
}

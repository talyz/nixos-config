{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.home-assistant;
in
{
  options =
  {
    talyz.home-assistant =
    {
      enable = mkOption {
        default = false;
        example = true;
        description = "Whether to host the Home Assistant setup.";
        type = types.bool;
      };
    };
  };

  config = lib.mkMerge [
    (mkIf cfg.enable
      {
        virtualisation.oci-containers.containers = {
          home-assistant = {
            environment.TZ = config.time.timeZone;
            image = "ghcr.io/home-assistant/home-assistant:2024.9.0";
            extraOptions = [
              "--network=host"
              "--device=/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20240104165049-if00:/dev/ttyACM0"
            ];
            volumes = [
              "home-assistant:/config"
              "/run/dbus:/run/dbus:ro"
            ];
          };
        };

        environment.persistence.main.directories = [
          "/var/lib/containers"
        ];

        services.nginx = {
          enable = true;

          recommendedTlsSettings = true;
          recommendedOptimisation = true;
          recommendedGzipSettings = true;
          recommendedProxySettings = true;

          upstreams.hass.servers."127.0.0.1:8123" = {};
          virtualHosts."home-assistant.${config.talyz.domain.internal.domain}" = {
            locations."/" = {
              proxyPass = "http://hass";
              proxyWebsockets = true;
            };
            forceSSL = true;
            useACMEHost = config.talyz.domain.internal.domain;
          };
        };
        talyz.domain.internal.getCertificate = true;

        networking.firewall.allowedTCPPorts = [
          80    # HTTP
          1400  # Sonos
        ];
      })
    {
      talyz.domain.internal.services = [ "home-assistant" ];
    }
  ];
}

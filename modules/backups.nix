{ config, pkgs, lib, ... }:

let
  inherit (lib)
    mkOption
    mkMerge
    mkIf
    types;

  cfg = config.talyz.backups;
in
{
  options.talyz.backups =
    {
      enable = mkOption {
        default = builtins.length config.talyz.backups.paths > 0;
        description = "Whether to backup this machine.";
        type = types.bool;
      };
      time = mkOption {
        default = "12:00";
        description = "Time to run the backup.";
        type = types.str;
      };
      paths = mkOption {
        default = [];
        description = "Paths to backup.";
        type = types.listOf types.path;
      };
      exclude = mkOption {
        default = [];
        description = "Paths to exclude.";
        type = types.listOf types.path;
      };
    };

  config = mkMerge [
    (mkIf cfg.enable
      {
        services.restic.backups = {
          gdrive = {
            exclude = cfg.exclude;
            initialize = true;
            passwordFile = config.sops.secrets.restic-password.path;
            paths = cfg.paths;
            pruneOpts = [
              "--keep-daily 7"
              "--keep-weekly 5"
              "--keep-monthly 12"
              "--keep-yearly 3"
            ];
            rcloneConfigFile = config.sops.secrets.restic-rclone.path;
            rcloneOptions = {
              checksum = true;
              transfers = "30";
            };
            repository = "rclone:gdrive:restic/${config.networking.hostName}";
            runCheck = true;
            checkOpts = [
              "--read-data-subset=10%"
            ];
            timerConfig = {
              OnCalendar = cfg.time;
            };
          };
        };

        environment.persistence.cache.directories = [
          { directory = "/var/cache/restic-backups-gdrive"; mode = "0700"; }
        ];

        sops.secrets.restic-password = { };
        sops.secrets.restic-rclone = { };
      }
    )
  ];
}

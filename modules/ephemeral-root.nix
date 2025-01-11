{ config, lib, impermanence, ... }:

let
  cfg = config.talyz.ephemeralRoot;
  user = config.talyz.username;
in
{
  options.talyz.ephemeralRoot =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether the system uses an ephemeral root device and desired
          state should be linked to persistent storage.
        '';
      };

      home.mountDotfiles = lib.mkOption {
        default = true;
        description = ''
          Whether directories from /etc/nixos/modules/dotfiles should
          be bind mounted to /home/<user>.
        '';
      };

      home.extraFiles = lib.mkOption {
        default = [];
        example = [
          ".gnupg/pubring.kbx"
          ".gnupg/sshcontrol"
          ".gnupg/trustdb.gpg"
          ".gnupg/random_seed"
        ];
        description = ''
          Additional files in the home directory to link to persistent
          storage.
        '';
      };

      home.extraDirectories = lib.mkOption {
        default = [];
        example = [
          ".config/gsconnect"
        ];
        description = ''
          Additional directories in the home directory to link to
          persistent storage.
        '';
      };

      root.extraFiles = lib.mkOption {
        default = [];
        example = [
          "/etc/nix/id_rsa"
        ];
        description = ''
          Additional files in the root to link to persistent storage.
        '';
      };

      root.extraDirectories = lib.mkOption {
        default = [];
        example = [
          "/var/lib/libvirt"
        ];
        description = ''
          Additional directories in the root to link to persistent
          storage.
        '';
      };
    };


  config = lib.mkMerge [
    (lib.mkIf cfg.home.mountDotfiles {
      programs.fuse.userAllowOther = true;

      home-manager.users.${user} = { lib, ... }:
        {
          imports = [ impermanence.nixosModules.home-manager.impermanence ];

          home.persistence."/etc/nixos/modules/dotfiles" = {
            allowOther = true;
            removePrefixDirectory = true;
            files = [
              "screen/.screenrc"
            ];
          };
        };
    })

    (lib.mkIf cfg.enable {
      boot.initrd =
        let
          rootReset = ''
            mkdir /btrfs_tmp
            mount /dev/root_vg/root /btrfs_tmp
            if [[ -e /btrfs_tmp/root ]]; then
                mkdir -p /btrfs_tmp/old_roots
                timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
                mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
            fi

            delete_subvolume_recursively() {
                IFS=$'\n'
                for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                    delete_subvolume_recursively "/btrfs_tmp/$i"
                done
                btrfs subvolume delete "$1"
            }

            for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
                delete_subvolume_recursively "$i"
            done

            btrfs subvolume create /btrfs_tmp/root
            umount /btrfs_tmp
          '';
        in
          {
            systemd.enable = true;
            systemd.emergencyAccess = true;
            systemd.services = {
              root-reset = {
                wantedBy = [ "initrd-root-device.target" ];
                wants = [ "dev-root_vg-root.device" ];
                after = [ "dev-root_vg-root.device" ];
                before = [ "sysroot.mount" ];
                serviceConfig.Type = "oneshot";
                script = rootReset;
              };
            };
          };

      users.mutableUsers = false;
      users.users.${user} = {
        hashedPasswordFile = "/persistent/password_${user}";
        initialPassword = lib.mkForce null;
      };
      users.users.root.hashedPasswordFile = "/persistent/password_root";
    })

    {
      environment.persistence.main = {
        inherit (cfg) enable;
        persistentStoragePath = "/persistent";
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ] ++ cfg.root.extraFiles;
        directories = [
          { directory = "/etc/nixos"; mode = "0700"; user = "talyz"; group = "root"; }
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/docker"
          "/var/lib/nixos"
          "/var/lib/flatpak"
          "/var/lib/fprint"
          "/var/lib/tailscale"
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
        ] ++ cfg.root.extraDirectories;
        users.talyz = {
          directories = [
            "Downloads"
            "Music"
            "Pictures"
            "Documents"
            "Videos"
            "VirtualBox VMs"
            "Projects"
            "NoMachine"
            "XLN Audio Dropbox"
            ".aws"
            ".FlashPrint5"
            { directory = ".gnupg"; mode = "0700"; }
            { directory = ".ssh"; mode = "0700"; }
            ".mix"
            ".mozilla"
            ".emacs.d"
            { directory = ".nixops"; mode = "0700"; }
            { directory = ".nixops-managed-deployments"; mode = "0700"; }
            ".dropbox"
            ".dropbox-dist"
            ".local/share/containers"
            ".local/share/fish"
            ".local/share/evolution"
            { directory = ".local/share/keyrings"; mode = "0700"; }
            ".local/share/direnv"
            ".local/share/cura"
            ".local/share/flatpak"
            ".local/share/Steam"
            ".config/Bitwarden"
            ".config/chromium"
            ".config/discord"
            ".config/evolution"
            ".config/gcloud"
            ".config/goa-1.0"
            ".config/github-copilot"
            ".config/keepassxc"
            ".config/Slack"
            ".config/ClickUp"
            ".config/VirtualBox"
            ".config/cura"
            ".config/Element"
            ".cache/evolution"
            ".cache/lorri"
            ".cache/nix"
            ".cache/keepassxc"
            ".cache/flatpak"
          ] ++ cfg.home.extraDirectories;
          files = [
            ".config/monitors.xml"
          ] ++ cfg.home.extraFiles;
        };
      };

      virtualisation.vmVariant.virtualisation = {
        graphics = false;
        fileSystems = {
          "/" = {
            mountPoint = "/persistent";
            neededForBoot = true;
          };
          "/tmpfsroot" = {
            mountPoint = "/";
            fsType = "tmpfs";
            neededForBoot = true;
          };
        };
      };
    }
  ];
}

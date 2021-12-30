{ config, lib, pkgs, ... }:

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
          imports = [ ../modules/impermanence/home-manager.nix ];

          home.persistence."/etc/nixos/modules/dotfiles" = {
            allowOther = true;
            removePrefixDirectory = true;
            files = [
              "screen/.screenrc"
            ];
            directories = [
              "fish/.config/fish"
            ];
          };
        };
    })

    (lib.mkIf cfg.enable {
      users.mutableUsers = false;
      users.users.${user}.passwordFile = "/persistent/password_${user}";
      users.users.root.passwordFile = "/persistent/password_root";

      home-manager.users.${user} = { lib, ... }:
        {
          home.persistence."/persistent/home/${user}" = {
            allowOther = true;
            files = cfg.home.extraFiles;
            directories = [
              "Downloads"
              "Music"
              "Pictures"
              "Documents"
              "Videos"
              "VirtualBox VMs"
              "Projects"
              "NoMachine"
              "Dropbox (XLN Audio)"
              ".aws"
              ".gnupg"
              ".ssh"
              ".mozilla"
              ".emacs.d"
              ".nixops"
              ".nixops-managed-deployments"
              ".dropbox"
              ".dropbox-dist"
              ".local/share/containers"
              ".local/share/fish"
              ".local/share/evolution"
              ".local/share/keyrings"
              ".local/share/direnv"
              ".local/share/cura"
              ".local/share/flatpak"
              ".config/evolution"
              ".config/goa-1.0"
              ".config/keepassxc"
              ".config/Slack"
              ".config/VirtualBox"
              ".config/cura"
              ".cache/evolution"
              ".cache/lorri"
              ".cache/nix"
              ".cache/keepassxc"
              ".cache/flatpak"
            ] ++ cfg.home.extraDirectories;
          };
        };

      environment.persistence."/persistent" = {
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ] ++ cfg.root.extraFiles;
        directories = [
          "/etc/nixos"
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/docker"
          "/var/lib/flatpak"
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
        ] ++ cfg.root.extraDirectories;
      };
    })
  ];
}

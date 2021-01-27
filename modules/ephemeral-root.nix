{ config, lib, pkgs, ... }:

let
  cfg = config.talyz.ephemeralRoot;
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


  config = lib.mkIf cfg.enable
    {
      users.mutableUsers = false;
      users.users.talyz.passwordFile = "/persistent/password_talyz";
      users.users.root.passwordFile = "/persistent/password_root";

      programs.fuse.userAllowOther = true;

      home-manager.users.talyz = { lib, ... }:
        {
          home.persistence."/persistent/home/talyz" = {
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
              ".config/evolution"
              ".config/goa-1.0"
              ".config/keepassxc"
              ".config/Slack"
              ".config/VirtualBox"
              ".config/cura"
              ".cache/evolution"
              ".cache/lorri"
              ".cache/nix"
            ] ++ cfg.home.extraDirectories;
          };

          home.persistence."/etc/nixos/home-talyz-nixpkgs/dotfiles" = {
            removePrefixDirectory = true;
            allowOther = true;
            files = [
              "screen/.screenrc"
            ];
            directories = [
              "fish/.config/fish"
            ];
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
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
        ] ++ cfg.root.extraDirectories;
      };
    };
}

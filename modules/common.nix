{ config, lib, pkgs, deploy-rs, ... }:

{
  options = {
    talyz.username = lib.mkOption {
      type = lib.types.str;
      default = "talyz";
      description = ''
        The username to use for the main system user to which all
        home-manager configuration and ssh authorized_keys applies to,
        etc.
      '';
    };
  };

  config = {

    nix.settings = {
      cores = 0;
      experimental-features = [ "nix-command" "flakes" ];
      builders-use-substitutes = true;
    };

    programs.ssh.knownHosts."aarch64.nixos.community".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUTz5i9u5H2FHNAmZJyoJfIGyUm/HfGhfwnc142L3ds";

    # nix = {
    #   distributedBuilds = true;
    #   buildMachines = [
    #     {
    #       hostName = "aarch64.nixos.community";
    #       maxJobs = 64;
    #       sshKey = "/etc/nix/id_ed25519";
    #       sshUser = "talyz";
    #       system = "aarch64-linux";
    #       supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
    #     }
    #   ];
    # };

    environment.systemPackages = with pkgs; [
      deploy-rs.packages.${pkgs.system}.deploy-rs
      wget
      gnupg
      file
      tree
      killall
      git
      htop
      fzf
      fd
      curl
      sshfs-fuse
      exfat
      pv
      ripgrep
      openssh
      pciutils
      usbutils
      screen
      pwgen
      heimdal
      nix-index
      nixpkgs-review
      gh
      gocryptfs
      signing-party
      msmtp
      direnv
      dnsutils
      bat
      unzip
      jq
      comma
      delta
      duf
      ncdu
    ] ++ lib.optionals (pkgs.system == "x86_64-linux") [
      cpufrequtils
    ];

    boot.kernelParams = [
      ''cgroup_no_v1="all"''
      "systemd.unified_cgroup_hierarchy=1"
    ];
    systemd.services."user@".serviceConfig.Delegate = "pids memory cpu io";

    boot.plymouth.enable = true;

    # Internationalisation properties.
    console.keyMap = "dvorak";
    i18n.defaultLocale = "sv_SE.UTF-8";
    i18n.extraLocaleSettings.LC_MESSAGES = "en_US.UTF-8";

    time.timeZone = "Europe/Stockholm";

    nixpkgs.config.allowUnfree = true;

    documentation.man.generateCaches = true;

    programs.fish.enable = true;

    hardware.nitrokey.enable = true;

    home-manager.users.${config.talyz.username} = { ... }:
      {
        nixpkgs.config = import ./config.nix;
        xdg.configFile."nixpkgs/config.nix".source = ./config.nix;

        home.stateVersion = config.system.stateVersion;

        programs.fish = {
          enable = true;
          shellAbbrs = {
            shell = "nix-shell --run fish -p";
            tmp = "cd (mktemp -d)";
          };
          shellInit = ''
            eval (direnv hook fish)
            set fish_greeting ""
          '';
          functions = {
            fish_prompt = {
              description = "Write out the prompt";
              body = ''
                set retstatus $status

                if not set -q __fish_prompt_hostname
                    set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
                end

                if not [ -n "$PWD" ]
                    cd $HOME
                end

                if [ $retstatus = 0 ]
                    set smiley (set_color green)"^^"
                else
                    set smiley (set_color red)"-.-\""
                end

                if [ $TERM = screen-256color ]
                    set screen_title_escape "\033k$argv\033\\"
                else
                    set screen_title_escape ""
                end

                if fish_git_prompt >/dev/null
                    set git_prompt (fish_git_prompt)
                else
                    set git_prompt ""
                end

                printf '( %s%s %s@%s  %s  %s %s) %b' (set_color magenta)(prompt_pwd) (set_color red)$git_prompt (set_color green)$USER $__fish_prompt_hostname (set_color blue)$retstatus $smiley (set_color normal) $screen_title_escape
              '';
            };
          };
        };

        programs.git = {
          enable = true;
          userEmail = "kim.lindberger@gmail.com";
          userName = "talyz";
          signing = {
            key = "950336A4CA46BB42242733312DED2151F4671A2B";
            signByDefault = true;
          };
          delta = {
            enable = true;
            options = {
              navigate = true;
              side-by-side = true;
              true-color = "always";
            };
          };
        };

        programs.gpg.enable = true;
        programs.gpg.settings = {
          keyserver = "hkps://keys.openpgp.org";
          default-key = "950336A4CA46BB42242733312DED2151F4671A2B";
        };

        services.gpg-agent.enable = true;
        services.gpg-agent.enableSshSupport = true;
        services.gpg-agent.defaultCacheTtl = 14400;
        services.gpg-agent.maxCacheTtl = 86400;
        services.gpg-agent.defaultCacheTtlSsh = 14400;
        services.gpg-agent.maxCacheTtlSsh = 86400;
        services.gpg-agent.extraConfig = ''
          pinentry-program ${pkgs.pinentry-gnome3}/bin/pinentry
        '';

        programs.btop.enable = true;
        programs.btop.settings = {
          color_theme = "flat-remix";
        };

        systemd.user.startServices = true;

        services.lorri.enable = true;

        home.file = {
          ".direnvrc".text = ''
            use_nix() {
              eval "$(lorri direnv)"
            }
          '';
        };
      };

    services.openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
      startWhenNeeded = true;
    };

    users.users.root = {
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEARgkYNELcXVNbLWaVtXqlhDYMnYHX/9sNTR638PRz3DVo9tOI9ZVVsSAAJ9nnO6jx5DPM8rDQiO5k/TktQRPAhDyJfJ5skFhl30DGDs2xQ7cKgA/9wbul6lyhYOjii4cqHOKsFczQ1TDe2jT+XT6/GmhFaOTYtNPrpYpddAn0vU14YYyI8M5B/Yg/raphcTz7JCuiIkVFT3AnDccribQTkKvzXrfb/JoruScclaivUpTzVnycJrAazIV30kyrW3YettBP7Z/JEfXU+noZN2nZOthRkBxqFIJd6IAvoP2fNua40CltjE6I3PpILf00CB5F82ANb8Qd97zDR+md1SmIxLfKM0punLfGmTcnCrqL+dzVZnp9AZUNIShAX1Zz1jCJtLc7rzvt7IVAcA3Re9icWuKJVOhN1eLgsbIT35gmLw5wI5hHMijtOUSjNYGrLRZ70MFfR23ZYpzdory4VmOrJ/+XCN5YobK4eYcL/r/00Xbb1k7ARybFqrH7gDvFVFeHIGW7Ye8pvoIpJP7DL6K7RzG/EkOhH6gdGVKYsTGhQybiJzOAodmcQwJOxJXaoGHdOwBC4/+kPf2xrLDUGtADmwJWm4raEkA/F/Ybrvh/FtbZZKcivmTNyYA7OVyNZl9nP7YA/7yBvqbrhnKSxbPi6lce9BbVwBCZWkOiY3GAw== talyz@sythe-2023-11-20"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBpsBCSm1A+DuES6xkYlWv8+d7fhSbm6Y3vel/f4CIlD0j5k3H7NaojHvAnXoqhN/8sKKvURCe1XpwTVWytazufT+5rOQUr/0GiR+3nx8DQN08n1IDdMSUEtoEHP7lCUFgSfgCRftnWc8C6QpoMUAUvViebQU0wWqBo0fXcU4i/LCSYdEWO8+USIp1KQOvoyKX1dKwETeE2Ax9bHZBCrjRAS5iFFWnivJsq2lpQlxvTYDwhFXdNSf4Mo3nr9mRSnRfLM2vX2w2Klgyz8E+I+D05xXYGv9MozE4uduiqP9YD5LBtGKaVrWEOQkA4FYVo457OBDQkhOLIt6e8YYE9oa3lfudDbtVF8Wj+Sx/nf8LLGWnW+wytQ/bAu3YUy3MzONiLKkuAPlfEX2EMTTbZCOjou5MuXe7GarHJuOV0d5m/Ka+oNm8c/E+60KTA5HXqMvvGTLyxTJuCBYVJDyvOUZNTsGyIo2+TX21jn6Y3Z3vqHI/WYgQ0WKkMkuAz0RDyeempUHfgvqNHhnTGQLFhLDMfPdyldyB+o4i527nYOriyw8xh5OOCmDeBO1QqKSQye/hsliw5C6m01kAdNO27yF9bTYmT4nqhmYHSdbvQj++dX3O8GFcQycZiqd9qH8LjlQAfkKegLC2dnePGFtSSXPwu4yEA7tMXVvDjfAYN9qkxw== openpgp:0x347109EF"
      ];
    };

    users.users.${config.talyz.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "flatpak" ];
      shell = pkgs.fish;
      uid = 1000;
      initialPassword = "aoeuaoeu";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYb+iWquRt4aA7ARpLqsoRrjsku+YLFv0IzSu2rxCl6SWLLCqq0x4fayPJq0K8nVIJQcp8E1gj5x9IY54JxKH/T3IOiUYSPFdd79xZj32xwGojoMDab0c9YoOGA/GCnJeqawrsB2eDvQb1QFrxQ6L4/ooCiD0s0o/DZPzp1SaaQMGdpVrPQJlsGpejjoinT2NMB1VkRECtF6U1GnT9wfxYqZxmRzvKkfzim+IWpUft94lFP2uaY2veVC19YdMBiiRYHhG4q3gCeCanbbZlwi+I7uv5fcxAK4qsbWQ4z6uFBw4Zovkr/X8nGBxIytSY79/wdC/IvxUXmyo9xbWGpOrR8lXVt8fWwKm8NZHH6xdo3BJa7uYAzHOpw9mOFbAnPcd7KZN8OouYsycRlB/1/wfsd5HTqJfUJc/P5aK1I2UEVAF7jpgXMy8H7qIVRD7hBr7u6gGD+R0NQT+kGgueEyrolFsD+X/3PnzhBZIzU9XgOfHP3MJRph6hNW5EvpX9ZDmJBSHmvJNeKbMHr/w59d3ojbnQJDTzoe2n2SHRxJtFPUkOy2w6YrDsoTpfe7/xYDiamXjVpoVkIIeKRL67VLL07gvoGYf1w8G90G7lPT7h/tEgXBzcDoF8uZjgkHezVh2eHl7KNnxyjAslFC0lcxJ7dD5hIwV33WhXXuphy5SnWQ== talyz@natani-2020-09-14"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxpS0/cz+daRaLFagSCK9SEd5bq8wmZs+yUbktgsiMQsfh3fT8kK5P7O7DjZBJMrPRwXJU6BNCGpe08755kdVw1gNfDDUyiUznqM1Q3Uzvb0dvOMm16RgLRb8da8ilNxIVXI5cO0MKzZJM06aTZfPyP9bFIUCIL9DP3wu91ts+vlBuOCcFymzf7B5uTZUpHaoq2Aq8+xeBUnF9stdBJ35yJihIIZCIZ2hSMpfV7lrKgyzgUJugO9WoGIsKgaro2r8Em7IiWdAfLa/OAunEw7Crau4sJrwBXLSqRxor/H8wUHWzfDqm1YvL1yMShVe4Fv/2V7uXxhsA5xHbboGe7tkPaURaUhySgUxycjZhFT/fNqJyU0/xUyrJMGA+5Ml9dY3NeTMJKUBeyt18yj8gAh4gqRzLtcsgSveQB1h5nVYO3xP1ydhLYrfZ4XJkEhSix8YhfEr+pxCwSC/9cx2w/H+10aQgQJqI15llfBL1Rl24g0f+VcawuWdahRL0sDUYQLBt5FRNn/SKBu/PGGU5XW4Ox0Zw7wSJZ0ukPORwaRFPgMC2IpDk14bqBEG6VVWYuSSq01IOAnwNqcrcsKFXA/+9OV5wgYOpxjQwIx5bA41T8RsbrrgENMAlm3VkUOgWz50wuMQfWR7fXrmqehsvmmG/fJo9ro56W908y9val2cCVw== talyz@flora-2019-06-24"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClEBWe28hb+GRtpa0MdKh/2UKPIANBEeDuXlcfHgS4Mi4gTNKMWjclXhBzEYfRLpYEZuBjcciRTKNKUjMi4aSmc3g6/FoueaDTmHhoQWCEFwrR7m1ZwplHYZuad2Dm6kOMXyi3VIw1y4u3K832LsTrrgBeDT+C23qVfjvmeytD7tWnoEqgDKnrdxZYqiNdu43HA5V7r7jXCMVby2/39iqa+AxKBxt/v1gz7rar3jr/6EfE55oJpQfj8wFGLq88IK915eTTEVYSZLUxZkfOaZGMjkyMiXNTLWtJ/MfBQ0SagDwwuZKf/+C/O1vO6scz6Uc9wBUPPbUnhUkGzO/kWduXiXLQfEwYrFVAd2HyrErwnuJs/0HSWYm/c6o4O1xaDaqj+bcfGewK+EEPU+J1P0MwXTLgpJ6r0VkzrKd/r0kVUrxXqhrMdSwtl6M3CgqDc3rFgiV5xs4nRjnwbhchud77ktZ3zV40uLYXHa5IlldN4O91MD1+LVffc5eceJmhn9ivuoEk+w/Wwtk8c/G2axakfmF9H4VFRgzyVnKrel2Gz4gZd1wihA2B8o4eh10pEmeS5O0BRDXpJGMC3FKCelX42mEYy4qr6bCF4Bqo0+bQOHgzZpdQQ+utmvrYlMVVcJMqh2xjSbaPdC+trOa0fvVBFTXIAF/Wn/1zFj6+G6mCYQ== talyz@zen-2018-11-16"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIU/OtOXEgYB3tKfQ2cyGvfkMs9lVTK7yXrEfFpYWuLg2DC3c7PLMRpkKviJsyWHtfRvun42HalJz0aWrbBHbym8La/KaOarMnxltCLCrSr87ig0AlS7ETUc8iDz5utRtRK081tauh86Vm2GwDGodCx0kf/C9YPL00dNAV28Zc+R7PrtcwJ9VGtg3ik5u8fE11qa3gEg8wYH1z1mZEJ3FmEDUOJSGypIe87AvjwmoeEQ5GzcyuFfEzy4IFgMOmZLaN/3gGbvc3xGVr3SLmciOh+Rw0pNCjR8+GqEcYhgRvHA8PCDtYF3Mp8LNPlSpnHpzu7CzdExpZHGv91TIYaaQzY+jmy4qMi3oCN5MmNeGNd27D5jGESbMheKSV8Xs9g5WDZVvmyU/qh4JUi+ruh/mgH2dfQ8b8MvbJrgNOjyWSVIR4BSQ2GvY+KrOHvaD7qiPP8P/WVXGWqS1tXOEDSaQwouYyTlj6HAKr6NdFV9GXMmd8aWcJCssLvhGQa9O+RzhibGlj9cinFIdaaZBi8wJ5xynicpFjsDjCtaxirBGt0VTonKKmyDyqVuT9lYmY2BBcYKv2EeuOMC2FPwxC6wuTtSPkc1Y7hB8n0dw2ZW3lRaQEPgH8fl6buh0fj4UAEztDc9yK7Bt3Kb7L7KA/8UGTzXwWYoP9R9v8kyXj1mXFjQ== talyz@evals-2020-05-18"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoybGcGH2jH9l2p1Jyk9nWAyNkKqA/SBET+koXM2mbQAnmKpL8SKUNN4K/NQJAqEaGNTn2F6dl1w7SOg4AOajIlbGPOpyR/XgE+QptqZ+9K6vSL1ZcVc0PHnaspbfAIUT5rMR3mYN6SudL+w4ybd4afsC6TOJ2555cZdm8AQDbgYzoQM0Gc6RRRNmOaU5hzGeWj1ssx1R+rPv8O4aR5vKrlVIZKnIxlOHPtac9SpRxxCkb4U+N30lTestugxwpZrlEtNdJ5hhec8Hs8Buyh2DW7KkOlXbvmiPMDysBQECnBnZPLN5RlL5h983ngUkN3ShHlOXOez2fTakisxcfJppm0bLMb1zYOGolqU9mkl3LRJRojdnEeoDICyB9Lzn58RWFUHTzOWtjCK5zZSelnX/TZ6MPwWg6nMi92a2fB57OV/VkDsam8qRBsEQQIcXFBNSXU0j7TlEOlAYbjlNELOatJnHrp+q85MI3S0mOP+YEAagSUC6zSGKr2pgV4Vf3fGVUKMpkWOynPNs6mNn3lziWBUdbjb7iZDKZmQbcwI9NGAAv5VTkYhWMepludNbXeRCwlMNNQYmZPS/q/e7D40MK3++/eJJsalo3eML9bdZEuy1Xske+1wdw0xRSilLQtVRPXHNziVqejb7HQY0t4hGSlij4kky0bsWMSfetI29qbw== talyz@trace-2020-12-10"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEARgkYNELcXVNbLWaVtXqlhDYMnYHX/9sNTR638PRz3DVo9tOI9ZVVsSAAJ9nnO6jx5DPM8rDQiO5k/TktQRPAhDyJfJ5skFhl30DGDs2xQ7cKgA/9wbul6lyhYOjii4cqHOKsFczQ1TDe2jT+XT6/GmhFaOTYtNPrpYpddAn0vU14YYyI8M5B/Yg/raphcTz7JCuiIkVFT3AnDccribQTkKvzXrfb/JoruScclaivUpTzVnycJrAazIV30kyrW3YettBP7Z/JEfXU+noZN2nZOthRkBxqFIJd6IAvoP2fNua40CltjE6I3PpILf00CB5F82ANb8Qd97zDR+md1SmIxLfKM0punLfGmTcnCrqL+dzVZnp9AZUNIShAX1Zz1jCJtLc7rzvt7IVAcA3Re9icWuKJVOhN1eLgsbIT35gmLw5wI5hHMijtOUSjNYGrLRZ70MFfR23ZYpzdory4VmOrJ/+XCN5YobK4eYcL/r/00Xbb1k7ARybFqrH7gDvFVFeHIGW7Ye8pvoIpJP7DL6K7RzG/EkOhH6gdGVKYsTGhQybiJzOAodmcQwJOxJXaoGHdOwBC4/+kPf2xrLDUGtADmwJWm4raEkA/F/Ybrvh/FtbZZKcivmTNyYA7OVyNZl9nP7YA/7yBvqbrhnKSxbPi6lce9BbVwBCZWkOiY3GAw== talyz@sythe-2023-11-20"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvQd1ynzHQ76KJmu67iBOAe70WMCw2O0tMEBzXGxXkhBvHGNGsHdfQgZ3zFQQPeBvwIMEUcQIXTjmCX7Upo37UhUK4uRyGKkLOQ1C5B5gdBjLJYmPqqlQd6EAIYjEZaDkMQ8VCWLbM1oYLf9PjK84WynvFGAkWzTORblCmba5TO8rHVUSIXzIwopiiiIlQ2wwB4x3UMJq2yWYXh0wYskeZ3jxmRpjdn4jOCx+5MSa4vk+6z3CUk45ULknP4QXxUxMa4IjO0EJ0edpuZJnS8P8ElKinpROYvChXx2Ho0bVLyWBV6/9OLFLK3LpYHsxspGcK7PR8FOIYkUiRlNUZgSdhwVvGlLOvtfbRDv09ZHLmrP+N+LfOc9fhFTWbCs3MxrTi9bUrG79dJw2SZMBpjEzEN2Wq/9DqcxXpxpO0GOHcm4XlAyj5TgKBqxPdeKBGGHDf7S2CrzfVcbOzxh8iG+WQSfSE7YcltX7XfuSHrmEdZRi+ShrmF9+0Zw9/k7Th4u/NUHUyRaN7xhBBW1aotK8euw3DNyc+Sri2cxhtGMIydzjBybPYU45KnjkkJIlFWgCUULNoaEG8v4P+DOQ4/8XGVAzrrawQQWUq5QSQ1M1r7s9BEcPpjvDm8z11MkPwBT1CrGTEAlvKjgCsvFp6VYOSVxrsX3Tg5FlFOVCBl3JTtw== talyz@raine"
      ];
    };
  };
}

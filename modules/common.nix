{ config, lib, pkgs, ... }:

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

    nix.buildCores = 0;

    nix.extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
    '';

    programs.ssh.knownHosts."aarch64.nixos.community".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUTz5i9u5H2FHNAmZJyoJfIGyUm/HfGhfwnc142L3ds";

    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "aarch64.nixos.community";
          maxJobs = 64;
          sshKey = "/etc/nix/id_ed25519";
          sshUser = "talyz";
          system = "aarch64-linux";
          supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
        }
      ];
    };

    environment.systemPackages = with pkgs; [
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
      gocryptfs
      signing-party
      msmtp
      direnv
      dnsutils
      bat
      unzip
      jq
      cpufrequtils
      delta
      duf
    ];

    boot.kernelParams = [
      ''cgroup_no_v1="all"''
      "systemd.unified_cgroup_hierarchy=1"
    ];
    systemd.services."user@".serviceConfig.Delegate = "pids memory cpu io";

    # Internationalisation properties.
    console.font = "Lat2-Terminus16";
    console.keyMap = "dvorak";
    i18n.defaultLocale = "sv_SE.UTF-8";
    i18n.extraLocaleSettings.LC_MESSAGES = "en_US.UTF-8";

    time.timeZone = "Europe/Stockholm";

    nixpkgs.config.allowUnfree = true;

    documentation.man.generateCaches = true;

    programs.fish.enable = true;

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
        services.gpg-agent.extraConfig = ''
          pinentry-program ${pkgs.pinentry-gnome}/bin/pinentry-gnome3
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
      kbdInteractiveAuthentication = false;
      passwordAuthentication = false;
      permitRootLogin = "no";
      startWhenNeeded = true;
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
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIl7rJCJVP+1CfwRuzQtllxXjhpe3i0ZiiWtGsQ6V3o5/BgBO4kAlkmWWG/bASpRuy8GyDhErGbZUi48pjvsJzGMgDV+ZN+1d4OLeKUOAk1Xvyo/sb5e/NPXT00Zb1x9kqcfPtpEKyGiEpDYYhfz76v+AsyOYHAxoWxV3mwro0xalPDps0fJCF/XVXouBMeI7xqm4ot+4sCPNVNyLYvv2FK6Xw+TDJCEje5o4ELuD4iKUcIUfUD/pFeosrsAhi8O0LuZub7dO5qLiA+Z6LuMCeqF/hJ/rK8Unt+YC77bAg272YztXrngKlEyZ4AaB8ZIql9DEJEMPqYR2Lu/YMAs9qvamk004cb2z/ZqwG42Tyurlgo6Pau6VarlIENycrZey5EIhm4nQspP+75Pd0uOnpxP5MTbu7YEC1FdUYWhk9itTCHpEPvMCyOByl4t60KeNSRC7+Ksx0qGyPEz1aPYxIHl3b5lCkTDlXV5P2Nf+TvZXQZUMqqvdOCqgoVjYxqMofebw88iBeiDP01uxRRc7xFyecyPm/EKkfk8+LTfI00cXo9t/PsHUhwexaALAjdnx3EKsOPT6TjGNDHc6o58ORXcaajmMQP6EgYSqoibx8/cGXrAevA+DPnwBzLUQ3aikt3f0PDt2I5Yj/o3Aykr+BnbTfQ1mGwxRAoMBg1CWgWw== kim.lindberger@Kims-Mac-mini.local"
      ];
    };
  };
}

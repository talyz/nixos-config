{ config, lib, pkgs, ... }:

{
  options.talyz.work =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to enable work related settings.
        '';
      };
    };

  config = lib.mkIf config.talyz.work.enable
    {
      environment.systemPackages = with pkgs;
        [
          slack
          bitwarden
          nomachine-client
          zoom-us
          libreoffice
          awscli2
          age
          openssl
          google-cloud-sdk
          imgp
          clickup
        ];

      # virtualisation.libvirtd.enable = true;
      # virtualisation.libvirtd.qemuRunAsRoot = false;
      # virtualisation.libvirtd.onShutdown = "shutdown";
      # users.users.${config.talyz.username}.extraGroups = [ "libvirtd" ];
      # networking.firewall.checkReversePath = false;

      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.host.enableExtensionPack = true;

      virtualisation.podman.enable = true;
      virtualisation.podman.dockerCompat = true;

      services.avahi.browseDomains = [ "internal.xlnaudio.com" ];

      # Enable CUPS to print documents.
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          hplipWithPlugin
          postscript-lexmark
          canon-cups-ufr2
          carps-cups
          cnijfilter2
          cnijfilter_2_80
          cnijfilter_4_00
          cups-bjnp
          gutenprintBin
        ];
      };

      # Enable printer configuration
      #hardware.printers.ensureDefaultPrinter = "Lexmark_CS510de";
      # hardware.printers.ensurePrinters = [
      #   {
      #     name = "Lexmark_CS510de";
      #     deviceUri = "ipps://192.168.0.124:443/ipp/print";
      #     model = "postscript-lexmark/Lexmark-CS510_Series-Postscript-Lexmark.ppd";
      #     location = "UFS";
      #     ppdOptions = {
      #       PageSize = "A4";
      #     };
      #   }
      # ];

      # Enable SANE to scan documents.
      services.saned.enable = true;
      hardware.sane.enable = true;
      hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];
      hardware.sane.netConf = "printer.internal.xlnaudio.com";

      users.users.${config.talyz.username}.extraGroups = [
        "lp"
        "scanner"
        "vboxusers"
      ];

      nix.buildMachines = [
        # {
        #   hostName = "zen";
        #   sshUser = "root";
        #   system = "x86_64-linux";
        #   maxJobs = 2;
        #   supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        # }
        {
          hostName = "meshify-ml";
          sshUser = "root";
          system = "x86_64-linux";
          maxJobs = 2;
          supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        }
      ];
      nix.distributedBuilds = true;
      # nix.extraOptions = ''
      #   builders-use-substitutes = true
      # '';
      # nix.binaryCaches = lib.mkAfter [ "ssh-ng://zen" ];
      nix.settings.trusted-public-keys = [
        "zen:/mViKdKKlduW1kwAGKauOPM0dg3Jfe6Z4Yosho+54PU="
        "xln:SXLx65clGonsiGSfCbOWvq6zI3leKKc92+mUZ1tMWUQ="
      ];

      programs.ssh.knownHosts = {
        zen = {
          extraHostNames = [ "zen" "192.168.1.106" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyFlaKS43N8ZqheVodC2g1Xo0Z/HvvI+aekYHw9bIIS";
        };
        meshify-ml = {
          extraHostNames = [ "meshify-ml" "10.0.1.32" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBaJD+r5QWS53sEWoClxs/lIcDl+hdO6OS1ERlqpYpLD";
        };
      };

      programs.ssh.extraConfig = ''
        Host zen
            Hostname 192.168.1.106
            User root
            IdentitiesOnly yes
            IdentityFile /etc/nix/id_rsa
        Host meshify-ml
            Hostname 10.0.1.32
            User root
            IdentitiesOnly yes
            IdentityFile /etc/nix/id_rsa
      '';
      talyz.ephemeralRoot.root.extraFiles = [
        "/etc/nix/id_rsa"
      ];
    };
}

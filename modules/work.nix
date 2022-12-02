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
        ];

      programs.ssh.extraConfig = ''
        GSSAPIAuthentication yes
      '';

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
        drivers = [
          pkgs.hplipWithPlugin
          pkgs.postscript-lexmark
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
        # "vboxusers"
      ];
    };
}

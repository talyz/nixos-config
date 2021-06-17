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
          nomachine-client
          zoom-us
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

      users.users.${config.talyz.username}.extraGroups = [ "vboxusers" ];

      services.avahi.browseDomains = [ "internal.xlnaudio.com" ];
    };
}

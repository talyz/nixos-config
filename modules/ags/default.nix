{
  ags,
  pkgs,
  config,
  ...
}:
let
  user = config.talyz.username;
in
{
  home-manager.users.${user} = { lib, config, ... }:
  let
    requiredDeps = with pkgs; [
      config.wayland.windowManager.hyprland.package
      bash
      coreutils
      gawk
      imagemagick
      inotify-tools
      procps
      ripgrep
      util-linux
      systemd
    ];

    guiDeps = with pkgs; [
      gnome.gnome-control-center
      mission-center
      overskride
      pwvucontrol
      wlogout
    ];

    dependencies = requiredDeps ++ guiDeps;

    cfg = config.programs.ags;
  in
  {
    imports = [
      ags.homeManagerModules.default
    ];

    programs.ags = {
      extraPackages = dependencies;
      systemd.enable = true;
      configDir = ./.;
    };

    systemd.user.services.ags = {
    #   Unit = {
    #     Description = "Aylur's Gtk Shell";
    #     PartOf = [
    #       "tray.target"
    #       "graphical-session.target"
    #       "hyprland-session.target"
    #     ];
    #   };
      Service = {
        Environment = [
          "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}"
          "XDG_DATA_DIRS=${lib.concatStringsSep ":" config.xdg.systemDirs.data}:/run/current-system/sw/share"
          # "XDG_DATA_DIRS=/run/current-system/sw/share"
        ];
    #     ExecStart = "${cfg.package}/bin/ags";
    #     Restart = "on-failure";
      };
    #   Install.WantedBy = [
    #     "graphical-session.target"
    #   ];
    };
  };
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.exwm;
  loadScript = ./exwm.el;
in
{
  options = {
    talyz.exwm = {
      enable = mkOption {
        default = false;
        example = true;
        description = "Whether to enable the exwm window manager.";
        type = types.bool;
      };
      lockerCommand = mkOption {
        default = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -n -f Noto-Sans-Regular";
      };
    };
  };
  config = mkIf cfg.enable {

    talyz.common-graphical.enable = true;

    programs.light.enable = true;
    programs.nm-applet.enable = true;

    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;

    talyz.emacs.extraPackages = epkgs: with epkgs; [
      desktop-environment
      exwm
    ];

    environment.systemPackages = with pkgs; [
      flameshot
    ];

    services.xserver.windowManager.session = singleton {
      name = "exwm";
      start = ''
          # Bind gpg-agent to this TTY if gpg commands are used.
          export GPG_TTY=$(tty)

          # SSH agent protocol doesn't support changing TTYs, so bind the agent
          # to every new TTY.
          ${pkgs.gnupg}/bin/gpg-connect-agent --quiet updatestartuptty /bye > /dev/null

          if [ -z "$SSH_AUTH_SOCK" ]; then
          export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
          fi

          systemctl --user import-environment

          ${pkgs.xss-lock}/bin/xss-lock -l -- ${cfg.lockerCommand} &
          ${pkgs.emacs}/bin/emacs -l ${loadScript}
        '';
    };
  };
}

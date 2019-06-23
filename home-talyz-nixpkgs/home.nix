{ pkgs, ... }:

{ 
  imports = [ ./host.nix ];

  pam.sessionVariables =
  {
    EDITOR = "emacs";
    MOZ_USE_XINPUT2 = "1";
  };

  programs.git =
  {
    enable = true;
    userEmail = "kim.lindberger@gmail.com";
    userName = "talyz";
  };

  gtk.enable = true;
  gtk.iconTheme = {
    package = pkgs.gnome3.adwaita-icon-theme;
    name = "Adwaita";
  };
  gtk.gtk3.extraConfig = {
    gtk-cursor-theme-name = "Adwaita";
    gtk-application-prefer-dark-theme = 1;
  };

  systemd.user.startServices = true;

  home.file =
  {
    ".emacs".source = ./dotfiles/emacs/emacs;
    "emacs-config.el".source = pkgs.runCommand "emacs-config.el" {} ''
      cp ${./dotfiles/emacs/emacs-config.org} emacs-config.org
      ${pkgs.emacs}/bin/emacs --batch ./emacs-config.org -f org-babel-tangle
      mv emacs-config.el $out
    '';
    
    ".screenrc".source = ./dotfiles/screen/screenrc;
    ".config/fish/config.fish".source = ./dotfiles/fish/.config/fish/config.fish;
    ".config/fish/functions/cal.fish".source = ./dotfiles/fish/.config/fish/functions/cal.fish;
    ".config/fish/functions/ec.fish".source = ./dotfiles/fish/.config/fish/functions/ec.fish;
    ".config/fish/functions/fish_prompt.fish".source = ./dotfiles/fish/.config/fish/functions/fish_prompt.fish;

    ".config/Dharkael/flameshot.ini".text = ''
      [General]
      disabledTrayIcon=true
      drawColor=#ff0000
      drawThickness=0
    '';

    # Create the auto-saves directory
    ".emacs.d/auto-saves/.manage-directory".text = "";
  };
}

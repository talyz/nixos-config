{ pkgs, ... }:

{
  imports = [ ./modules/persistence.nix ];
  
  pam.sessionVariables = {
    EDITOR = "emacs";
    MOZ_USE_XINPUT2 = "1";
  };

  programs.git = {
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

  services.dunst.enable = true;
  services.dunst.iconTheme = {
    package = pkgs.gnome3.adwaita-icon-theme;
    name = "Adwaita";
  };
  services.dunst.settings =  {
    global = {
      geometry = "500x5-30+50";
      padding = 8;
      horizontal_padding = 8;
      frame_color = "#eceff1";
      font = "Droid Sans 11";
    };

    urgency_normal = {
      background = "#37474f";
      foreground = "#eceff1";
      timeout = 10;
    };
  };

  home.persistence."/persistent/home/talyz".directories = [
    "Downloads"
    "Music"
    "Pictures"
    "Documents"
    "Videos"
    ".ssh"
    ".mozilla"
    ".emacs.d"
  ];

  home.persistence."/etc/nixos/home-talyz-nixpkgs/dotfiles" = {
    removePrefixDirectory = true;
    files = [
      "screen/.screenrc"
    ];
    directories = [
      "fish/.config/fish"
    ];
  };
  
  home.file =
  {
    ".emacs".source = pkgs.runCommand "emacs" (with pkgs; { inherit cquery; }) ''
      substituteAll ${./dotfiles/emacs/emacs} $out
    '';
    "emacs-config.el".source = pkgs.runCommand "emacs-config.el" {} ''
      cp ${./dotfiles/emacs/emacs-config.org} emacs-config.org
      ${pkgs.emacs}/bin/emacs -Q --batch ./emacs-config.org -f org-babel-tangle
      mv emacs-config.el $out
    '';

    ".config/Dharkael/flameshot.ini".text = ''
      [General]
      disabledTrayIcon=true
      drawColor=#ff0000
      drawThickness=0
    '';

    # Create the auto-saves directory
    # ".emacs.d/auto-saves/.manage-directory".text = "";
  };
}

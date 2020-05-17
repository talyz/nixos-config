{ pkgs, ... }:

{
  imports = [ ./modules/persistence.nix ];
  
  pam.sessionVariables = {
    EDITOR = "emacs";
    MOZ_USE_XINPUT2 = "1";
  };

  nixpkgs.config = import ./config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./config.nix;

  programs.git = {
    enable = true;
    userEmail = "kim.lindberger@gmail.com";
    userName = "talyz";
    signing = {
      key = "950336A4CA46BB42242733312DED2151F4671A2B";
      signByDefault = true;
    };
    extraConfig = {
      submodule.recurse = true;
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

  gtk.enable = true;
  gtk.iconTheme = {
    package = pkgs.gnome3.adwaita-icon-theme;
    name = "Adwaita";
  };
  gtk.gtk3.extraConfig = {
    gtk-cursor-theme-name = "Adwaita";
    gtk-application-prefer-dark-theme = 1;
  };

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "org.gnome.Evince.desktop" ];
    "image/pdf" = [ "org.gnome.Evince.desktop" ];
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

  home.persistence."/persistent/home/talyz" = {
    files = [];
    directories = [
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "VirtualBox VMs"
      "Projects"
      ".aws"
      ".gnupg"
      ".ssh"
      ".mozilla"
      ".emacs.d"
      ".nixops"
      ".local/share/fish"
      ".local/share/evolution"
      ".local/share/keyrings"
      ".local/share/direnv"
      ".config/evolution"
      ".config/goa-1.0"
      ".config/VirtualBox"
      ".cache/evolution"
    ];
  };

  home.persistence."/etc/nixos/home-talyz-nixpkgs/dotfiles" = {
    removePrefixDirectory = true;
    files = [
      "screen/.screenrc"
    ];
    directories = [
      "fish/.config/fish"
    ];
  };

  services.lorri.enable = true;

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

    ".config/kitty/kitty.conf".text = ''
      font_family       Fira Code Retina
      bold_font         Fira Code Bold
      italic_font       Fira Code Italic
      bold_italic_font  Fira Code Bold Italic
      font_size         11.0
      repaint_delay     1
      input_delay       1
      term              kitty
    '';

    ".direnvrc".text = ''
      use_nix() {
        eval "$(lorri direnv)"
      }
    '';

    # Create the auto-saves directory
    # ".emacs.d/auto-saves/.manage-directory".text = "";
  };
}

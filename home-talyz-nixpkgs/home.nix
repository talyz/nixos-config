{ pkgs, ... }:

{ 
  imports = [ ./host.nix ];
  # home.sessionVariableSetter = "pam";
  # home.sessionVariables = { EDITOR = "emacs";
  # 			    MOZ_USE_XINPUT2 = "1";
  # 			  };

  pam.sessionVariables =
  {
    EDITOR = "emacs";
    MOZ_USE_XINPUT2 = "1";
  };
  
  programs.emacs =
  {
    enable = true;
    extraPackages = epkgs: map (package: epkgs.${package}) [
      "use-package"
      "nix-mode"
      "magit"
      "fish-mode"
      "webpaste"
      "yasnippet"
      "yasnippet-snippets"
      "ivy-yasnippet"
      "popup"
      "undo-tree"
      "multiple-cursors"
      "magit"
      "smooth-scrolling"
      "sr-speedbar"
      "projectile"
      "ace-window"
      "flx"
      "ivy"
      "swiper"
      "counsel"
      "ivy-rich"
      "systemd"
      "highlight-symbol"
      "flycheck"
      "flycheck-pos-tip"
      "cmake-mode"
      "cmake-font-lock"
      "company"
      "company-quickhelp"
      "paredit"
      "xah-lookup"
      "company-c-headers"
      #"realgud"
      "rtags"
      "cmake-ide"
      "macrostep"
      "elpy"
      "yaml-mode"
      "company-ansible"
      "ansible-doc"
      "org"
      #"weechat"
      "dracula-theme"
      "telephone-line"
    ];
  };

  programs.git =
  {
    enable = true;
    userEmail = "kim.lindberger@gmail.com";
    userName = "talyz";
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
  };
}

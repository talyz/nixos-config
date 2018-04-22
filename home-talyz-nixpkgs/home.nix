{ pkgs, ... }:

{ 
  programs.home-manager.enable = true;
  programs.home-manager.path = https://github.com/rycee/home-manager/archive/master.tar.gz;
    
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
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.magit
      epkgs.zerodark-theme
      epkgs.fish-mode
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
    "emacs-config.org".source = ./dotfiles/emacs/emacs-config.org;
    ".screenrc".source = ./dotfiles/screen/screenrc;
    ".config/fish/config.fish".source = ./dotfiles/fish/.config/fish/config.fish;
    ".config/fish/functions/cal.fish".source = ./dotfiles/fish/.config/fish/functions/cal.fish;
    ".config/fish/functions/ec.fish".source = ./dotfiles/fish/.config/fish/functions/ec.fish;
    ".config/fish/functions/fish_prompt.fish".source = ./dotfiles/fish/.config/fish/functions/fish_prompt.fish;
  };
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.exwm;
  loadScript = ./exwm.el;
  inherit (pkgs.callPackage ./elisp.nix {}) fromEmacsUsePackage;
  #  packages = epkgs: map (package: epkgs.${package}) (cfg.extraPackages ++ [ "desktop-environment" "exwm" ]);
  unbreakRtagsComponent = pkg: pkg.overrideAttrs (oldAttrs: {
    meta = (oldAttrs.meta or {}) // { broken = false; };
    configurePhase = " ";
  });
  orgBabelTangeledConfig = (pkgs.runCommand "emacs-config.el" {} ''
      cp ${../home-talyz-nixpkgs/dotfiles/emacs/emacs-config.org} emacs-config.org
      ${pkgs.emacs}/bin/emacs --batch ./emacs-config.org -f org-babel-tangle
      mv emacs-config.el $out
    '');
  exwm-emacs = (fromEmacsUsePackage {
    config = "${orgBabelTangeledConfig}";
    override = epkgs: epkgs // {
      weechat = epkgs.melpaPackages.weechat;
      elpy = epkgs.melpaPackages.elpy;
      company-rtags = (unbreakRtagsComponent epkgs.company-rtags);
      flycheck-rtags = (unbreakRtagsComponent epkgs.flycheck-rtags);
      ivy-rtags = (unbreakRtagsComponent epkgs.ivy-rtags);
      nix-mode = epkgs.nix-mode.overrideAttrs (oldAttrs: {
        version = "20190110.701";
        src = pkgs.fetchFromGitHub {
          owner = "NixOS";
          repo = "nix-mode";
          rev = "80a1e96c7133925797a748cf9bc097ca6483baeb";
          sha256 = "1sn2077vmn71vwjvgs7a5prlp94kyds5x6dyspckxc78l2byb661";
        };
        recipe = builtins.fetchurl {
          url = "https://github.com/melpa/melpa/blob/master/recipes/nix-mode";
          sha256 = "10f3ly4860lkxzykw4fbvhn3i0c2hgj77jfjbhlk2c1jz9x4yyy5";
          name = "recipe";
        };
      });
    };
  });
in
{
  options =
  {
    talyz.exwm = {
      enable = mkOption {
        default = false;
        example = true;
        description = "Whether to enable the exwm window manager.";
        type = types.bool;
      };
      extraPackages = mkOption {
        default = [];
        example = literalExample ''
          epkgs: [
          epkgs.emms
          epkgs.magit
          epkgs.proofgeneral
          ]
        '';
        description = ''
          Extra packages available to Emacs. The value must be a
          function which receives the attrset defined in
          <varname>emacsPackages</varname> as the sole argument.
        '';
      };
      lockerCommand = mkOption {
        default = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
      };
    };
  };
  config =
    mkIf cfg.enable (mkMerge [
      ((import ../profiles/common-graphical.nix) { inherit config pkgs; })
      {
        nixpkgs.overlays =
          let
            nixos-git = (import /home/talyz/nixpkgs {
              config.allowUnfree = true;
            });
          in
          [
            (self: super:
              {
                emacsPackagesNgFor = nixos-git.emacsPackagesNgFor;
              }
            )
            (import
              (builtins.fetchTarball
                {
                  url = https://github.com/adisbladis/exwm-overlay/archive/master.tar.gz;
                }))
          ];
        # services.dunst.enable = true;

        programs.light.enable = true;

        environment.systemPackages = with pkgs; [
          flameshot
        ];

        services.xserver.windowManager.session = singleton {
          name = "exwm";
          start = ''
            ${pkgs.compton}/bin/compton --backend glx &
            nm-applet &
            ${pkgs.xss-lock}/bin/xss-lock -- ${cfg.lockerCommand} &
            ${exwm-emacs}/bin/emacs -l ${loadScript}
          '';
        };
      }
    ]);
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.emacs;

  overlay = self: super:
    let
      inherit (super.callPackage ./emacs-with-use-package-pkgs/emacs-with-use-package-pkgs.nix
                                 { pkgs = super; }) emacsWithUsePackagePkgs;

      orgBabelTangeledConfig = (super.runCommand "emacs-config.el" {} ''
        cp ${../home-talyz-nixpkgs/dotfiles/emacs/emacs-config.org} emacs-config.org
        ${super.emacs}/bin/emacs --batch ./emacs-config.org -f org-babel-tangle
        mv emacs-config.el $out
      '');

      unbreakRtagsComponent = pkg: pkg.overrideAttrs (oldAttrs: {
        meta = (oldAttrs.meta or {}) // { broken = false; };
        configurePhase = " ";
      });
    in
    {
      emacs = (emacsWithUsePackagePkgs {
        config = "${orgBabelTangeledConfig}";
        extraPackages = cfg.extraPackages;
        override = epkgs: epkgs // {
          weechat = epkgs.melpaPackages.weechat;
          elpy = epkgs.melpaPackages.elpy;
          company-rtags = (unbreakRtagsComponent epkgs.company-rtags);
          flycheck-rtags = (unbreakRtagsComponent epkgs.flycheck-rtags);
          ivy-rtags = (unbreakRtagsComponent epkgs.ivy-rtags);
          nix-mode = epkgs.nix-mode.overrideAttrs (oldAttrs: {
            version = "20190119";
            src = super.fetchFromGitHub {
              owner = "NixOS";
              repo = "nix-mode";
              rev = "1e53bed4d47c526c71113569f592c82845a17784";
              sha256 = "172s5lxlns633gbi6sq6iws269chalh5k501n3wffp5i3b2xzdyq";
            };
            recipe = builtins.fetchurl {
              url = "https://github.com/melpa/melpa/blob/master/recipes/nix-mode";
              sha256 = "10f3ly4860lkxzykw4fbvhn3i0c2hgj77jfjbhlk2c1jz9x4yyy5";
              name = "recipe";
            };
          });
        };
      });
      rtags = super.rtags.override {
        emacs = super.emacs;
      };
    };
in
{
  options =
  {
    talyz.emacs = {
      enable = mkOption {
        default = true;
        example = false;
        description = "Whether to use my special emacs configuration system-wide.";
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
    };
  };
  config =
    {
      nixpkgs.overlays =
        [
          overlay
        ];

      services.emacs = {
        enable = true;
        defaultEditor = true;
      };
    };
}

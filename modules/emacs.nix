{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.emacs;

  overlay = self: super:
    let
      inherit (import ./emacs-with-use-package-pkgs/emacs-with-use-package-pkgs.nix
                      {
                        inherit (super) runCommand emacs emacsPackagesNgGen;
                      }) emacsWithUsePackagePkgs;

      orgBabelTangeledConfig = (super.runCommand "emacs-config.el" {} ''
        cp ${../home-talyz-nixpkgs/dotfiles/emacs/emacs-config.org} emacs-config.org
        ${super.emacs}/bin/emacs --batch ./emacs-config.org -f org-babel-tangle
        mv emacs-config.el $out
      '');
    in
    {
      emacs = (emacsWithUsePackagePkgs {
        config = "${orgBabelTangeledConfig}";
        extraPackages = cfg.extraPackages;
        override = epkgs: epkgs // {
          weechat = epkgs.melpaPackages.weechat;
          elpy = epkgs.melpaPackages.elpy;
          dracula-theme = epkgs.melpaPackages.dracula-theme.overrideAttrs (oldAttrs: oldAttrs // {
            src = super.fetchFromGitHub {
              owner = "talyz";
              repo = "dracula-emacs";
              rev = "a4c41005cb58208932b6d9ec99c8d912e42c634a";
              sha256 = "0bp3adn9w08zrps0dgwhcmwcifzld8lsq92rsad5hcvnqhvjfkc7";
            };
          });
        };
      });
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
        install = true;
        defaultEditor = true;
      };
    };
}

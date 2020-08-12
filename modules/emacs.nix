{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.emacs;

  overlay = self: super:
    {
      emacs = (super.emacsWithPackagesFromUsePackage {
        config = ../home-talyz-nixpkgs/dotfiles/emacs/emacs-config.org;
        package = super.emacs;
        extraEmacsPackages = cfg.extraPackages;
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
        default = _: [];
        example = literalExample ''
          epkgs: with epkgs; [
            emms
            magit
            proofgeneral
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
          (import ./emacs-overlay)
          overlay
        ];

      services.emacs = {
        install = true;
        defaultEditor = true;
      };
    };
}

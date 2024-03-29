{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.emacs;
  user = config.talyz.username;

  emacs = (pkgs.emacsWithPackagesFromUsePackage {
    config = ./dotfiles/emacs/emacs-config.org;
    package = pkgs.emacsPgtk;
    extraEmacsPackages = epkgs: [ epkgs.copilot ] ++ (cfg.extraPackages epkgs);
    override = epkgs: epkgs // {
      # weechat = epkgs.melpaPackages.weechat;
      weechat =  epkgs.melpaPackages.weechat.overrideAttrs (oldAttrs: oldAttrs // {
        src = pkgs.fetchFromGitHub {
          owner = "bqv";
          repo = "weechat.el";
          rev = "446868de424170be0584980d4dcc0859f7077d54";
          sha256 = "12vbp35z3hgr9lqplc7ycf8n2rfd0zarr50arc9bqy5z14pf3biv";
        };
      });
      elpy = epkgs.melpaPackages.elpy;
      dracula-theme = epkgs.melpaPackages.dracula-theme.overrideAttrs (oldAttrs: oldAttrs // {
        src = ./dracula-emacs;
      });

      # Install copilot.el
      copilot = epkgs.trivialBuild {
        pname = "copilot";
        version = "2023-04-27";

        packageRequires = with epkgs; [ dash editorconfig s ];

        preInstall = ''
          mkdir -p $out/share/emacs/site-lisp
          cp -vr $src/dist $out/share/emacs/site-lisp
        '';

        src = pkgs.fetchFromGitHub {
          owner = "zerolfx";
          repo = "copilot.el";
          rev = "7cb7beda89145ccb86a4324860584545ec016552";
          sha256 = "sha256-57ACMikRzHSwRkFdEn9tx87NlJsWDYEfmg2n2JH8Ig0=";
        };
      };
    };
  });

  languageServers = with pkgs; [
    elixir_ls
    gopls
    ccls
    cmake-language-server
    rnix-lsp
    python3Packages.python-lsp-server
    nodejs # For copilot.el
  ];

  emacsWithLanguageServers =
    pkgs.runCommand "emacs-with-language-servers" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${emacs}/bin/emacs $out/bin/emacs --prefix PATH : ${lib.makeBinPath languageServers}
    '';
in
{
  options =
  {
    talyz.emacs = {
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
        ];

      home-manager.users.${user} = { lib, ... }:
        {
          home.file = {
            ".emacs".source = ./dotfiles/emacs/emacs;
            "emacs-config.el".source = pkgs.runCommand "emacs-config.el" {} ''
              cp ${./dotfiles/emacs/emacs-config.org} emacs-config.org
              ${pkgs.emacs}/bin/emacs -Q --batch ./emacs-config.org -f org-babel-tangle
              mv emacs-config.el $out
            '';

            # Create the auto-saves directory
            # ".emacs.d/auto-saves/.manage-directory".text = "";
          };
        };

      environment.sessionVariables.EDITOR = "emacs";

      environment.systemPackages = [
        emacsWithLanguageServers
      ];
    };
}

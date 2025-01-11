{ config
, lib
, pkgs
, dotfiles
, dracula-emacs
, emacs-overlay
, ...
}:

let
  inherit (lib)
    mkOption
    literalExample
  ;

  cfg = config.talyz.emacs;
  user = config.talyz.username;

  emacs = (pkgs.emacsWithPackagesFromUsePackage {
    config = "${dotfiles}/emacs/emacs-config.org";
    defaultInitFile = true;
    package = pkgs.emacs.override {
      withPgtk = true;
    };
    extraEmacsPackages = epkgs: [ epkgs.copilot epkgs.treesit-grammars.with-all-grammars ] ++ (cfg.extraPackages epkgs);
    override = epkgs: (cfg.extraOverrides epkgs) // {
      elpy = epkgs.melpaPackages.elpy;
      dracula-theme = epkgs.melpaPackages.dracula-theme.overrideAttrs (oldAttrs: oldAttrs // {
        src = dracula-emacs;
      });
    };
  });

  languageServers = with pkgs; [
    elixir_ls
    gopls
    clang-tools
    cmake-language-server
    cmake
    nil
    # nixd
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
      # configFile = mkOption {
      #   description = ''
      #     Emacs config file.
      #   '';
      # };
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
      extraOverrides = mkOption {
        default = _: {};
      };
    };
  };
  config =
    {
      nixpkgs.overlays = [ emacs-overlay.overlays.default ];

      home-manager.users.${user} = { lib, ... }:
        {
          home.file = {
            # ".emacs".source = ./dotfiles/emacs/emacs;
            # "emacs-config.el".source = pkgs.runCommand "emacs-config.el" {} ''
            #   cp ${./dotfiles/emacs/emacs-config.org} emacs-config.org
            #   ${pkgs.emacs}/bin/emacs -Q --batch ./emacs-config.org -f org-babel-tangle
            #   mv emacs-config.el $out
            # '';

            # Create the auto-saves directory
            # ".emacs.d/auto-saves/.manage-directory".text = "";
          };
        };

      services.emacs.package = emacsWithLanguageServers;

      environment.sessionVariables.EDITOR = "emacs";

      environment.systemPackages = [
        emacsWithLanguageServers
      ];
    };
}

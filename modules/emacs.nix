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
      cmake-integration = epkgs.trivialBuild {
        pname = "cmake-integration";
        version = "2023-08-25";

        packageRequires = with epkgs; [ f s ];

        preInstall = ''
          mkdir -p $out/share/emacs/site-lisp
        '';

        src = pkgs.fetchFromGitHub {
          owner = "darcamo";
          repo = "cmake-integration";
          rev = "018ef1e847ce0909c202800e69021d7477ac13ab";
          sha256 = "sha256-FjZ13htVdngds8fiobqUiVo01rnKES73AjOiLY0xr4M=";
        };
      };
    };
  });

  languageServers = with pkgs; [
    elixir_ls
    gopls
    clang-tools
    lldb
    gdb
    cmake-language-server
    cmake
    nil
    # nixd
    nodePackages.bash-language-server
    python3Packages.python-lsp-server
    nodejs # For copilot.el
    "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters"
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
      enable = lib.mkOption {
        default = true;
        type = lib.types.bool;
        example = false;
        description = ''
          Whether to install and use my Emacs setup.
        '';
      };

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

  config = lib.mkIf cfg.enable
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

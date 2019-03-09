{ pkgs, stdenv }:

with builtins;

let
  usePackageNameExtract = pkgs.runCommand "use-package-name-extract" {}
    ''
      mkdir $out
      cp ${./use-package-name-extract.el} "$out/use-package-name-extract.el"
      ${pkgs.emacs}/bin/emacs --no-site-file --batch \
                              --eval "(byte-compile-file \"$out/use-package-name-extract.el\")"
    '';

  packageList = dotEmacs:
    pkgs.runCommand "usePackagePackageList" {}
                    ''${pkgs.emacs}/bin/emacs ${dotEmacs} --no-site-file --batch \
                                              -l ${usePackageNameExtract}/use-package-name-extract.el \
                                              -f print-packages 2> $out'';
  
  parsePackages = dotEmacs:
    filter (x: x != "")
           (filter (x: typeOf x == "string")
                   (split "\n"
                          (readFile (packageList dotEmacs))));
  
  fromEmacsUsePackage = {
    config,
    package ? pkgs.emacs,
    override ? (epkgs: epkgs),
    extraPackages ? []
  }:
  let
    packages = parsePackages config;
    emacsPackages = pkgs.emacsPackagesNgGen package;
    emacsWithPackages = emacsPackages.emacsWithPackages;
  in emacsWithPackages (epkgs:
                          let
                            overridden = override epkgs;
                          in map (name: if hasAttr name overridden then
                                          overridden.${name}
                                        else
                                          null)
                                 (packages ++ [ "use-package" ] ++ extraPackages ));
in {
  inherit fromEmacsUsePackage;
}

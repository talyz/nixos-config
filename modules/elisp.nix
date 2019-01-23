{ pkgs, stdenv }:

with builtins;

let
  usePackageNameExtract = pkgs.callPackage ./use-package-name-extract/shell.nix {};
  
  parsePackages = dotEmacs:
    filter (x: x != "")
           (filter (x: typeOf x == "string")
                   (split "\n"
                          (readFile
                            (pkgs.runCommand "usePackagePackageList"
                                             {}
                                             ''${usePackageNameExtract}/bin/use-package-name-extract \
                                               ${dotEmacs} > $out''))));
  
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

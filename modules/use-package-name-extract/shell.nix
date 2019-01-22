{ pkgs ? import <nixpkgs> {} }:

with pkgs;

python3Packages.buildPythonPackage rec {
  pname = "use-package-name-extract";
  version = "1";
  format = "other";
  unpackPhase = " ";
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  src = ./use-package-name-extract.py;
}

# stdenv.mkDerivation rec {
  #   name = "env";
  #   env = buildEnv { name = name; paths = buildInputs; };
  #   buildInputs = [
    #     python3
    #     python37Packages.virtualenv
    #     python37Packages.pip
    #     python37Packages.elpy
    #   ];
  # }

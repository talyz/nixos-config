{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "gnome-shell-extension-show-workspaces-${version}";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "psimonyi";
    repo = "gse-show-workspaces";
    rev = "925e64679b1379f365a0c4df13e45082640cbb7a";
    sha256 = "0m6qq6jp012s2dnvx7844cwxss23a8diipnw3d4khs8jkw5wk2m6";
  };

  # Taken from the extension download link at
  # https://extensions.gnome.org/extension/1351/show-workspaces/
  uuid = "gse-show-workspaces@ns.petersimonyi.ca";

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp extension.js $out/share/gnome-shell/extensions/${uuid}
    cp metadata.json $out/share/gnome-shell/extensions/${uuid}
  '';

  meta = with stdenv.lib; {
    description = "Expands the workspaces in the overview, like before gnome 3.6";
    license = licenses.gpl2;
    maintainers = with maintainers; [ talyz ];
    homepage = https://github.com/psimonyi/gse-show-workspaces;
  };
}

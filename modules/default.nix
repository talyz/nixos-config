{ ... }:

{
  imports =
    [
      ./common.nix
      ./work.nix
      ./gnome.nix
      ./exwm.nix
      ./emacs.nix
      ./ephemeral-root.nix
      ./common-graphical.nix
      ./media-center.nix
      ./cachix.nix
    ];
}

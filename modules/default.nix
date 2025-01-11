{ ... }:

{
  imports =
    [
      ./common.nix
      ./work.nix
      ./gnome.nix
      ./hyprland.nix
      ./exwm.nix
      ./emacs.nix
      ./ephemeral-root.nix
      ./common-graphical.nix
      ./media-center.nix
      ./cachix.nix
      ./anyrun.nix
      ./ags
      ./wlogout.nix
      ./home-assistant.nix
      ./domain.nix
      ./vaultwarden.nix
      ./backups.nix
    ];
}

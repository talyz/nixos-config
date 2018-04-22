{
  imports = [
    ./common.nix
    ./common-graphical.nix
    ./gnome.nix
  ];
  
  services.tlp = {
    enable = true;
    extraConfig =
    ''
      CPU_HWP_ON_AC=performance
      USB_AUTOSUSPEND=0
      START_CHARGE_THRESH_BAT0=75
      STOP_CHARGE_THRESH_BAT0=80
      RUNTIME_PM_ON_BAT=on
    '';
  };
}

{ config, pkgs, ... }:

let
  home-manager-master = (builtins.fetchTarball {
    url = https://github.com/rycee/home-manager/archive/master.tar.gz;
  });
in
{
  nix.buildCores = 0;

  imports = [ "${home-manager-master}/nixos" ];
  
  environment.systemPackages = with pkgs; [
    wget
    ag
    gnupg
    stow
    file
    tree
    killall
    git
    htop
    fzf
    curl
    sshfs-fuse
    pv
    ripgrep
    openssh
    pciutils
    usbutils
    screen
    pwgen
    heimdalFull
    nix-index
    gocryptfs
    signing-party
    msmtp
    direnv
    dnsutils
  ];

  # Internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "dvorak-sv-a1";
    defaultLocale = "en_US.UTF-8";
  };
  
  time.timeZone = "Europe/Stockholm";

  nixpkgs.config.allowUnfree = true;
  #android_sdk.accept_license = true;

  programs.adb.enable = true;
  
  programs.fish.enable = true;

  home-manager.users.talyz = import ../home-talyz-nixpkgs/home.nix;

  users.extraUsers.talyz = {
    isNormalUser = true;
		extraGroups = [ "wheel" "video" "adbusers" "lp" "scanner" ];
		shell = pkgs.fish;
		uid = 1000;
		initialPassword = "aoeuaoeu";
	};
}

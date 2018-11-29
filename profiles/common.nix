{ config, pkgs, ... }:

{
  nix.buildCores = 0;
  
  environment.systemPackages = with pkgs; [
    wget
    ag
    gnupg
    stow
    file
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
  ];

  # Internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "dvorak-sv-a1";
    defaultLocale = "en_US.UTF-8";
  };
  
  time.timeZone = "Europe/Stockholm";

  nixpkgs.config.allowUnfree = true;
  
  programs.fish.enable = true;

  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  users.extraUsers.talyz = {
    isNormalUser = true;
		extraGroups = [ "wheel" ];
		shell = pkgs.fish;
		uid = 1000;
		initialPassword = "aoeuaoeu";
	};
}

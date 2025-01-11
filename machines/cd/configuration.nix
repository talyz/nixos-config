{ pkgs, lib, nixpkgs, dotfiles, ... }:
{
  imports = [
    # "${pkgs.path}/nixos/modules/installer/scan/not-detected.nix"
    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
    ../../modules
  ];

  talyz.gnome.enable = true;
  #talyz.exwm.enable = true;

  # Use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  #services.xserver.displayManager.gdm.wayland = false;

  hardware.pulseaudio.enable = lib.mkForce false;

  services.xserver.videoDrivers = [
    "amdgpu"
    "ati"
    "cirrus"
    "intel"
    "vesa"
    "vmware"
    "modesetting"
    "nouveau"
  ];

  nix.settings.cores = 0;

  services.getty.autologinUser = lib.mkForce null;

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  # users.users.nixos = {
  #   shell = pkgs.fish;
  #   openssh.authorizedKeys.keys = [
  #     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5RDs62krOSjnSS26y9nPpP0jpIHSO9uQ1tMVd4kAuQlAp0Q1Nfq9YwImXccdDl/wEycreT17wRLO9Oq8w2Nlnp4d7Xe+5acadcCSNx0rd8773357/n/QK2GyPa9ysDP3HnNLK6QhBf4GVdtCoHflk1liONzSdhiCGPHvpYFowG67cZTzb4/YPvryS//478OEa2JutTrP+N7fjH+SHuzndiWSNvWXTlqXWIufXKPqFzaKueLuABUSLe/Sj7ZNJhcMrBPUKmtKCQSbrAmdYvk5WzX6FacMlUWACNDceXH31u7OVLXDjQYU2jlc5E3s60erNlHlLtRGSd+wqCQv21ttlhCi9EVqdByEGv9ZGjt9lq4GS0ZHZCHTts17hjYSYql2QnYyx5ypSLOyqSjA5n34V3QUcVCCBk8QCt4wrWKqmU79TSOK0ihCaZiYlicQcKUgGdU/ouGgWp9+fUu4BqNKG8EIEmgIgbvJoe0QohDTJ9EyAkxMUz3L6KhFpVv3Zd470pChYgCMsjowrKJAWzq75UszCelRTFIylmE7LmAo9OSU8MHSD3ihf07NNXa0rw1t15pMOFjCwQWj2ea3tBeUUVLb4BTdiH4P//5lsHckeA6d1xtniP7HQXJ3Vft6IL+igZ/npL4yK412yMXm05ufzfG8dsuMW4k9eVQbXBQeeOQ== talyz@natani-2018-02-12"
  #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC0Ny2gtIq74qiHph/5ZUyNkdVTTXj2lnuDRHpgR3fPi talyz@flora-2017-01-10"
  #     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClEBWe28hb+GRtpa0MdKh/2UKPIANBEeDuXlcfHgS4Mi4gTNKMWjclXhBzEYfRLpYEZuBjcciRTKNKUjMi4aSmc3g6/FoueaDTmHhoQWCEFwrR7m1ZwplHYZuad2Dm6kOMXyi3VIw1y4u3K832LsTrrgBeDT+C23qVfjvmeytD7tWnoEqgDKnrdxZYqiNdu43HA5V7r7jXCMVby2/39iqa+AxKBxt/v1gz7rar3jr/6EfE55oJpQfj8wFGLq88IK915eTTEVYSZLUxZkfOaZGMjkyMiXNTLWtJ/MfBQ0SagDwwuZKf/+C/O1vO6scz6Uc9wBUPPbUnhUkGzO/kWduXiXLQfEwYrFVAd2HyrErwnuJs/0HSWYm/c6o4O1xaDaqj+bcfGewK+EEPU+J1P0MwXTLgpJ6r0VkzrKd/r0kVUrxXqhrMdSwtl6M3CgqDc3rFgiV5xs4nRjnwbhchud77ktZ3zV40uLYXHa5IlldN4O91MD1+LVffc5eceJmhn9ivuoEk+w/Wwtk8c/G2axakfmF9H4VFRgzyVnKrel2Gz4gZd1wihA2B8o4eh10pEmeS5O0BRDXpJGMC3FKCelX42mEYy4qr6bCF4Bqo0+bQOHgzZpdQQ+utmvrYlMVVcJMqh2xjSbaPdC+trOa0fvVBFTXIAF/Wn/1zFj6+G6mCYQ== talyz@zen-2018-11-16"
  #   ];
  # };

  boot.postBootCommands = lib.mkAfter ''
    mkdir -p /nix/var/nix/profiles/per-user/nixos
    mkdir -p /etc/nixos/modules
    cp -r ${dotfiles} /etc/nixos/modules/dotfiles
  '';
}

{ config, pkgs, ... }:

{
  nix.buildCores = 0;
  
  environment.systemPackages = with pkgs; [
    wget
    ag
    gnupg
    file
    tree
    killall
    git
    htop
    fzf
    fd
    curl
    sshfs-fuse
    exfat-utils
    pv
    ripgrep
    openssh
    pciutils
    usbutils
    screen
    pwgen
    heimdalFull
    nix-index
    nixpkgs-review
    gocryptfs
    signing-party
    msmtp
    direnv
    dnsutils
    bat
  ];

  boot.kernelParams = [
    ''cgroup_no_v1="all"''
    "systemd.unified_cgroup_hierarchy=1"
  ];
  systemd.services."user@".serviceConfig.Delegate = "pids memory cpu io";

  # Internationalisation properties.
  console.font = "Lat2-Terminus16";
  console.keyMap = "dvorak";
  i18n.defaultLocale = "en_US.UTF-8";
  
  time.timeZone = "Europe/Stockholm";

  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;

  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
    permitRootLogin = "no";
    startWhenNeeded = true;
  };

  home-manager.users.talyz = import ../home-talyz-nixpkgs/home.nix;

  users.users.talyz = {
    isNormalUser = true;
		extraGroups = [ "wheel" ];
		shell = pkgs.fish;
		uid = 1000;
		initialPassword = "aoeuaoeu";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5RDs62krOSjnSS26y9nPpP0jpIHSO9uQ1tMVd4kAuQlAp0Q1Nfq9YwImXccdDl/wEycreT17wRLO9Oq8w2Nlnp4d7Xe+5acadcCSNx0rd8773357/n/QK2GyPa9ysDP3HnNLK6QhBf4GVdtCoHflk1liONzSdhiCGPHvpYFowG67cZTzb4/YPvryS//478OEa2JutTrP+N7fjH+SHuzndiWSNvWXTlqXWIufXKPqFzaKueLuABUSLe/Sj7ZNJhcMrBPUKmtKCQSbrAmdYvk5WzX6FacMlUWACNDceXH31u7OVLXDjQYU2jlc5E3s60erNlHlLtRGSd+wqCQv21ttlhCi9EVqdByEGv9ZGjt9lq4GS0ZHZCHTts17hjYSYql2QnYyx5ypSLOyqSjA5n34V3QUcVCCBk8QCt4wrWKqmU79TSOK0ihCaZiYlicQcKUgGdU/ouGgWp9+fUu4BqNKG8EIEmgIgbvJoe0QohDTJ9EyAkxMUz3L6KhFpVv3Zd470pChYgCMsjowrKJAWzq75UszCelRTFIylmE7LmAo9OSU8MHSD3ihf07NNXa0rw1t15pMOFjCwQWj2ea3tBeUUVLb4BTdiH4P//5lsHckeA6d1xtniP7HQXJ3Vft6IL+igZ/npL4yK412yMXm05ufzfG8dsuMW4k9eVQbXBQeeOQ== talyz@natani-2018-02-12"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxpS0/cz+daRaLFagSCK9SEd5bq8wmZs+yUbktgsiMQsfh3fT8kK5P7O7DjZBJMrPRwXJU6BNCGpe08755kdVw1gNfDDUyiUznqM1Q3Uzvb0dvOMm16RgLRb8da8ilNxIVXI5cO0MKzZJM06aTZfPyP9bFIUCIL9DP3wu91ts+vlBuOCcFymzf7B5uTZUpHaoq2Aq8+xeBUnF9stdBJ35yJihIIZCIZ2hSMpfV7lrKgyzgUJugO9WoGIsKgaro2r8Em7IiWdAfLa/OAunEw7Crau4sJrwBXLSqRxor/H8wUHWzfDqm1YvL1yMShVe4Fv/2V7uXxhsA5xHbboGe7tkPaURaUhySgUxycjZhFT/fNqJyU0/xUyrJMGA+5Ml9dY3NeTMJKUBeyt18yj8gAh4gqRzLtcsgSveQB1h5nVYO3xP1ydhLYrfZ4XJkEhSix8YhfEr+pxCwSC/9cx2w/H+10aQgQJqI15llfBL1Rl24g0f+VcawuWdahRL0sDUYQLBt5FRNn/SKBu/PGGU5XW4Ox0Zw7wSJZ0ukPORwaRFPgMC2IpDk14bqBEG6VVWYuSSq01IOAnwNqcrcsKFXA/+9OV5wgYOpxjQwIx5bA41T8RsbrrgENMAlm3VkUOgWz50wuMQfWR7fXrmqehsvmmG/fJo9ro56W908y9val2cCVw== talyz@flora-2019-06-24"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClEBWe28hb+GRtpa0MdKh/2UKPIANBEeDuXlcfHgS4Mi4gTNKMWjclXhBzEYfRLpYEZuBjcciRTKNKUjMi4aSmc3g6/FoueaDTmHhoQWCEFwrR7m1ZwplHYZuad2Dm6kOMXyi3VIw1y4u3K832LsTrrgBeDT+C23qVfjvmeytD7tWnoEqgDKnrdxZYqiNdu43HA5V7r7jXCMVby2/39iqa+AxKBxt/v1gz7rar3jr/6EfE55oJpQfj8wFGLq88IK915eTTEVYSZLUxZkfOaZGMjkyMiXNTLWtJ/MfBQ0SagDwwuZKf/+C/O1vO6scz6Uc9wBUPPbUnhUkGzO/kWduXiXLQfEwYrFVAd2HyrErwnuJs/0HSWYm/c6o4O1xaDaqj+bcfGewK+EEPU+J1P0MwXTLgpJ6r0VkzrKd/r0kVUrxXqhrMdSwtl6M3CgqDc3rFgiV5xs4nRjnwbhchud77ktZ3zV40uLYXHa5IlldN4O91MD1+LVffc5eceJmhn9ivuoEk+w/Wwtk8c/G2axakfmF9H4VFRgzyVnKrel2Gz4gZd1wihA2B8o4eh10pEmeS5O0BRDXpJGMC3FKCelX42mEYy4qr6bCF4Bqo0+bQOHgzZpdQQ+utmvrYlMVVcJMqh2xjSbaPdC+trOa0fvVBFTXIAF/Wn/1zFj6+G6mCYQ== talyz@zen-2018-11-16"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIU/OtOXEgYB3tKfQ2cyGvfkMs9lVTK7yXrEfFpYWuLg2DC3c7PLMRpkKviJsyWHtfRvun42HalJz0aWrbBHbym8La/KaOarMnxltCLCrSr87ig0AlS7ETUc8iDz5utRtRK081tauh86Vm2GwDGodCx0kf/C9YPL00dNAV28Zc+R7PrtcwJ9VGtg3ik5u8fE11qa3gEg8wYH1z1mZEJ3FmEDUOJSGypIe87AvjwmoeEQ5GzcyuFfEzy4IFgMOmZLaN/3gGbvc3xGVr3SLmciOh+Rw0pNCjR8+GqEcYhgRvHA8PCDtYF3Mp8LNPlSpnHpzu7CzdExpZHGv91TIYaaQzY+jmy4qMi3oCN5MmNeGNd27D5jGESbMheKSV8Xs9g5WDZVvmyU/qh4JUi+ruh/mgH2dfQ8b8MvbJrgNOjyWSVIR4BSQ2GvY+KrOHvaD7qiPP8P/WVXGWqS1tXOEDSaQwouYyTlj6HAKr6NdFV9GXMmd8aWcJCssLvhGQa9O+RzhibGlj9cinFIdaaZBi8wJ5xynicpFjsDjCtaxirBGt0VTonKKmyDyqVuT9lYmY2BBcYKv2EeuOMC2FPwxC6wuTtSPkc1Y7hB8n0dw2ZW3lRaQEPgH8fl6buh0fj4UAEztDc9yK7Bt3Kb7L7KA/8UGTzXwWYoP9R9v8kyXj1mXFjQ== talyz@evals-2020-05-18"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIl7rJCJVP+1CfwRuzQtllxXjhpe3i0ZiiWtGsQ6V3o5/BgBO4kAlkmWWG/bASpRuy8GyDhErGbZUi48pjvsJzGMgDV+ZN+1d4OLeKUOAk1Xvyo/sb5e/NPXT00Zb1x9kqcfPtpEKyGiEpDYYhfz76v+AsyOYHAxoWxV3mwro0xalPDps0fJCF/XVXouBMeI7xqm4ot+4sCPNVNyLYvv2FK6Xw+TDJCEje5o4ELuD4iKUcIUfUD/pFeosrsAhi8O0LuZub7dO5qLiA+Z6LuMCeqF/hJ/rK8Unt+YC77bAg272YztXrngKlEyZ4AaB8ZIql9DEJEMPqYR2Lu/YMAs9qvamk004cb2z/ZqwG42Tyurlgo6Pau6VarlIENycrZey5EIhm4nQspP+75Pd0uOnpxP5MTbu7YEC1FdUYWhk9itTCHpEPvMCyOByl4t60KeNSRC7+Ksx0qGyPEz1aPYxIHl3b5lCkTDlXV5P2Nf+TvZXQZUMqqvdOCqgoVjYxqMofebw88iBeiDP01uxRRc7xFyecyPm/EKkfk8+LTfI00cXo9t/PsHUhwexaALAjdnx3EKsOPT6TjGNDHc6o58ORXcaajmMQP6EgYSqoibx8/cGXrAevA+DPnwBzLUQ3aikt3f0PDt2I5Yj/o3Aykr+BnbTfQ1mGwxRAoMBg1CWgWw== kim.lindberger@Kims-Mac-mini.local"
    ];
	};
}

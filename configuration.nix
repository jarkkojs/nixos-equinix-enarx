{ config, lib, pkgs, ... }:

{
  nix = {
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = "auto";
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems =  [ "aarch64-linux" ];
  boot.cleanTmpDir = true;

  i18n.defaultLocale = "en_US.UTF-8";
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = true;

  environment.loginShellInit = ''
    if [ -e $HOME/.profile ]
    then
      . $HOME/.profile
     fi
  '';

  services = {
    avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };
    openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
    };
    pcscd.enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    mosh.enable = true;
    mtr.enable = true;
  };

  environment.systemPackages = with pkgs; [
    bat
    bc
    bpftrace
    fzf
    gitFull
    gnutls
    htop
    killall
    libimobiledevice
    mc
    mutt
    msmtp
    neovim
    neovim-remote
    nixos-option
    p7zip
    pass
    pstree
    pv
    starship
    tmux
    trace-cmd
    tree
    unrar-wrapper
    unzip
    usbutils
    w3m
    wget
    xdg-utils
  ];

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "Hack" ]; })
  ];

  system.stateVersion = "22.11";
}

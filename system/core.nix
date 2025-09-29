# Core NixOS System Configuration
# Essential system-level settings that need root access
{ config, pkgs, userConfig, ... }:

{
  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    # Latest kernel for better hardware support
    kernelPackages = pkgs.linuxPackages_latest;
    # Clean /tmp on boot
    tmp.cleanOnBoot = true;
  };

  # Network configuration
  networking = {
    hostName = userConfig.hostname;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      # Allow common development ports (uncomment as needed)
      # allowedTCPPorts = [ 3000 8080 ];
    };
  };

  # Time and internationalization
  time.timeZone = userConfig.timezone;
  i18n = {
    defaultLocale = userConfig.locale;
    extraLocaleSettings = {
      LC_ADDRESS = userConfig.locale;
      LC_IDENTIFICATION = userConfig.locale;
      LC_MEASUREMENT = userConfig.locale;
      LC_MONETARY = userConfig.locale;
      LC_NAME = userConfig.locale;
      LC_NUMERIC = userConfig.locale;
      LC_PAPER = userConfig.locale;
      LC_TELEPHONE = userConfig.locale;
      LC_TIME = userConfig.locale;
    };
  };

  # Console (use X11 keymap configuration)
  console.useXkbConfig = true;

  # X11 keymap (also used by Wayland)
  services.xserver.xkb = {
    layout = userConfig.keyboardLayouts;
    options = userConfig.keyboardSwitchKey;
  };

  # Audio with PipeWire (modern audio server)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Graphics support (modern hardware.graphics replaces hardware.opengl)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # User account
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.name;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "uucp" ];
    shell = pkgs.zsh;
  };

  # System packages (minimal - user packages go in home.nix)
  environment.systemPackages = with pkgs; [
    # Essential system tools
    git
    wget
    curl
    vim
    htop
    tree
    unzip
    pciutils  # lspci
    usbutils  # lsusb
  ];

  # Enable shells
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Nerd Fonts for terminal/editor icons
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      # System fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      # Programming fonts
      source-code-pro
      hack-font
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Nix configuration
  nix = {
    settings = {
      # Enable flakes and new command-line tool
      experimental-features = [ "nix-command" "flakes" ];

      # Optimize storage
      auto-optimise-store = true;

      # Build performance
      max-jobs = "auto";
      cores = 0;  # Use all cores

      # Trusted users for binary cache
      trusted-users = [ "root" "@wheel" ];

      # Substituters for faster downloads
      substituters = [
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System state version - DON'T CHANGE after initial install
  system.stateVersion = "24.05";
}
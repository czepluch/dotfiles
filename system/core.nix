# Core NixOS System Configuration
# Essential system-level settings that need root access
{
  config,
  pkgs,
  userConfig,
  ...
}: {
  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    # Latest kernel for better hardware support
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "amdgpu.dcdebugmask=0x12"
      "iommu=pt"
      "pcie_aspm=force" # Enable ASPM for power saving
      "amdgpu.ppfeaturemask=0xffffffff" # Enable all power features
      "amdgpu.dpm=1" # Enable dynamic power management
    ];
    # Clean /tmp on boot
    tmp.cleanOnBoot = true;
  };

  hardware.enableRedistributableFirmware = true;

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

  # AMD GPU Configuration
  services.xserver.videoDrivers = ["amdgpu"];
  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = false; # Disable OpenCL if not needed
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Power button behavior - ignore short press
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # User account
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.name;
    extraGroups = ["wheel" "networkmanager" "audio" "video" "input" "uucp"];
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
    pciutils # lspci
    usbutils # lsusb

    # Command runner (for justfile)
    just

    # Power management
    powertop

    # GPU tools
    radeontop # AMD GPU monitoring
    lm_sensors # Temperature monitoring

    # Network tools
    networkmanager-openvpn
    networkmanagerapplet
  ];

  # Enable shells
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Enable nix-ld for running dynamically linked executables (e.g., Mason LSP servers)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    curl
  ];

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
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
        monospace = ["JetBrainsMono Nerd Font"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  # Nix configuration
  nix = {
    settings = {
      # Enable flakes and new command-line tool
      experimental-features = ["nix-command" "flakes"];

      # Optimize storage
      auto-optimise-store = true;

      # Build performance
      max-jobs = "auto";
      cores = 0; # Use all cores

      # Trusted users for binary cache
      trusted-users = ["root" "@wheel"];

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

  # System state version - DON'T CHANGE after initial install
  system.stateVersion = "25.05";
}

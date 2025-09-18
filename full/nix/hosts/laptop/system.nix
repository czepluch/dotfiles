# Slimbook Evo 14 AMD AI9 365 Configuration
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # System identification
  networking.hostName = "laptop";
  networking.hostId = "12345678"; # Generate with: head -c4 /dev/urandom | od -A none -t x4

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    # Use latest kernel for AMD AI9 365 support
    kernelPackages = pkgs.linuxPackages_latest;

    # Kernel parameters for AMD optimization
    kernelParams = [
      "amd_pstate=active"
      "amd_iommu=on"
      "iommu=pt"
    ];

    # Enable early loading of AMD graphics
    initrd.kernelModules = [ "amdgpu" ];
  };

  # Hardware optimization
  hardware = {
    # AMD GPU support
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
    };

    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    # CPU microcode
    cpu.amd.updateMicrocode = true;

    # Firmware updates
    enableAllFirmware = true;
  };

  # Power management for laptop
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # TLP for better battery life
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      START_CHARGE_THRESH_BAT0 = 20;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Networking
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 3000 8000 8080 ];
      allowedUDPPorts = [ ];
    };
    # Enable IPv6
    enableIPv6 = true;
  };

  # Localization
  time.timeZone = "Europe/Copenhagen";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_DK.UTF-8";
      LC_IDENTIFICATION = "en_DK.UTF-8";
      LC_MEASUREMENT = "en_DK.UTF-8";
      LC_MONETARY = "en_DK.UTF-8";
      LC_NAME = "en_DK.UTF-8";
      LC_NUMERIC = "en_DK.UTF-8";
      LC_PAPER = "en_DK.UTF-8";
      LC_TELEPHONE = "en_DK.UTF-8";
      LC_TIME = "en_DK.UTF-8";
    };
  };

  # Console keymap
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # User account
  users.users.dev = {
    isNormalUser = true;
    description = "Developer";
    extraGroups = [
      "wheel"           # sudo access
      "networkmanager"  # network management
      "docker"          # docker access
      "audio"           # audio devices
      "video"           # video devices
      "input"           # input devices
      "plugdev"         # removable devices
      "storage"         # storage management
    ];
    shell = pkgs.zsh;
  };

  # System packages (minimal - most handled by Home Manager)
  environment.systemPackages = with pkgs; [
    # Essential system tools
    git
    wget
    curl
    pciutils
    usbutils

    # File system tools
    ntfs3g
    exfat

    # Hardware monitoring
    lm_sensors
    amd-gpu-top
    radeontop

    # Network tools
    networkmanagerapplet
  ];

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Programming fonts
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Iosevka" ]; })

      # System fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      dejavu_fonts
      liberation_ttf

      # Microsoft fonts for compatibility
      corefonts
      vistafonts
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Enable Zsh system-wide
  programs.zsh.enable = true;

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # SSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Firmware updater
  services.fwupd.enable = true;

  # Printing support
  services.printing = {
    enable = true;
    drivers = with pkgs; [ cups-filters ];
  };

  # Enable CUPS for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  # Security
  security = {
    # Polkit for privilege escalation
    polkit.enable = true;

    # Realtime audio support
    rtkit.enable = true;

    # Sudo configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };
  };

  # XDG portals for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

  # This value determines the NixOS release compatibility
  # Don't change this after installation
  system.stateVersion = "24.05";
}

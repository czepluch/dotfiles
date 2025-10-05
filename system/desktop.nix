# Desktop Environment Configuration
# Hyprland and related services
{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # XDG Desktop Portal (for screen sharing, file picking, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # For file picker
    ];
  };

  # Login manager - greetd with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Allow greetd to access the seat
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Polkit (for authentication prompts)
  security.polkit.enable = true;

  # Essential desktop services
  services = {
    # D-Bus (required for most desktop functionality)
    dbus.enable = true;

    # Printing support
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Location service (for redshift/gammastep)
    geoclue2.enable = true;

    # Thumbnail generation
    tumbler.enable = true;

    # GVFS (for mounting external drives in file managers)
    gvfs.enable = true;

    # Power management
    upower.enable = true;
    power-profiles-daemon.enable = true;

    # Auto-switch power profiles based on AC status
    udev.extraRules = ''
      # Switch to power-saver when on battery
      SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
      # Switch to balanced when plugged in
      SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
    '';

    # Flatpak support (optional)
    flatpak.enable = true;
  };

  # Logind configuration for lid switch
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "suspend"; # Suspend when lid closes
      HandleLidSwitchDocked = "ignore"; # Don't do anything when docked
      HandleLidSwitchExternalPower = "suspend"; # Suspend even when plugged in
    };
  };

  # Environment variables for Wayland
  environment.sessionVariables = {
    # Wayland
    WAYLAND_DISPLAY = "wayland-1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # XDG
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";

    # SDL (games)
    SDL_VIDEODRIVER = "wayland";

    # Firefox
    MOZ_ENABLE_WAYLAND = "1";
  };

  # System packages for desktop environment
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wl-clipboard # Clipboard utilities
    wlr-randr # Monitor configuration
    wayland-utils # Wayland info tools

    # Screenshot and screen recording
    grim # Screenshot tool
    slurp # Area selection for screenshots
    wf-recorder # Screen recorder

    # File manager and archives
    xfce.thunar # File manager
    xfce.thunar-volman # Volume management
    xarchiver # Archive manager

    # Basic GUI applications
    pavucontrol # Audio control
    gnome-calculator
    eog # Image viewer

    # Theme and appearance
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
  ];
}

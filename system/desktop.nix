# Desktop Environment Configuration
# Hyprland and related services
{ config, pkgs, inputs, ... }:

{
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
      xdg-desktop-portal-gtk  # For file picker
    ];
  };

  # Login manager (SDDM with Wayland support)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # theme = "where_is_my_sddm_theme";  # Remove custom theme for now
  };

  # Polkit (for authentication prompts)
  security.polkit.enable = true;

  # Polkit authentication agent (for GUI password prompts)
  systemd.user.services.polkit-kde-authentication-agent-1 = {
    description = "polkit-kde-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

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

    # Flatpak support (optional)
    flatpak.enable = true;
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
    wl-clipboard          # Clipboard utilities
    wlr-randr            # Monitor configuration
    wayland-utils        # Wayland info tools

    # Screenshot and screen recording
    grim                 # Screenshot tool
    slurp                # Area selection for screenshots
    wf-recorder          # Screen recorder

    # File manager and archives
    xfce.thunar          # File manager
    xfce.thunar-volman   # Volume management
    xarchiver            # Archive manager

    # Basic GUI applications
    pavucontrol          # Audio control
    gnome-calculator
    eog                  # Image viewer

    # Theme and appearance
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
  ];
}
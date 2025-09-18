# Hyprland window manager system configuration
{ config, lib, pkgs, inputs, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  # Enable XWayland for compatibility
  programs.xwayland.enable = true;

  # Login manager configuration
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Audio support with PipeWire
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Graphics and hardware acceleration
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # XDG Desktop Portal configuration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  # Enable dconf for GTK applications
  programs.dconf.enable = true;

  # Bluetooth support
  services.blueman.enable = true;

  # System packages for Hyprland ecosystem
  environment.systemPackages = with pkgs; [
    # Core Hyprland tools
    waybar              # Status bar
    wofi                # Application launcher
    mako                # Notification daemon
    swww                # Wallpaper daemon
    hyprpaper           # Alternative wallpaper daemon

    # Screenshot and recording
    grim                # Screenshot utility
    slurp               # Screen area selection
    wf-recorder         # Screen recording
    swappy              # Screenshot editor

    # Clipboard management
    wl-clipboard        # Wayland clipboard utilities
    cliphist            # Clipboard history

    # File management
    dolphin             # File manager
    ark                 # Archive manager

    # System monitoring
    pavucontrol         # Audio control
    blueman             # Bluetooth management
    networkmanagerapplet # Network management

    # Themes and appearance
    qt5.qtwayland       # Qt Wayland support
    qt6.qmake           # Qt6 support
    libsForQt5.qt5ct    # Qt5 configuration tool
    libsForQt5.qtstyleplugin-kvantum # Kvantum theme engine

    # GTK themes
    adwaita-icon-theme  # GTK icon theme
    gnome.gnome-themes-extra # Additional GTK themes

    # Fonts for UI
    cantarell-fonts     # GTK default font

    # Authentication
    polkit-kde-agent    # Authentication agent

    # Power management
    brightnessctl       # Brightness control
    playerctl           # Media player control
  ];

  # Security and authentication
  security.polkit.enable = true;

  # Enable location services for automatic night mode
  services.geoclue2.enable = true;

  # Enable automatic login for seamless experience (optional)
  # Uncomment if you want automatic login
  # services.greetd.settings.default_session.user = "dev";

  # Environment variables for Wayland
  environment.sessionVariables = {
    # Wayland-specific
    WAYLAND_DISPLAY = "wayland-1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";

    # Qt
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";

    # GTK
    GDK_BACKEND = "wayland,x11";

    # Firefox
    MOZ_ENABLE_WAYLAND = "1";

    # Java applications
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # Electron applications
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";

    # NVIDIA (if using NVIDIA GPU)
    # Uncomment if you have NVIDIA hardware
    # LIBVA_DRIVER_NAME = "nvidia";
    # WLR_NO_HARDWARE_CURSORS = "1";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # Font configuration for better rendering
  fonts.fontconfig = {
    subpixel.rgba = "rgb";
    hinting = {
      enable = true;
      style = "slight";
    };
    antialias = true;
  };

  # Enable Plymouth for better boot experience
  boot.plymouth = {
    enable = true;
    theme = "breeze";
  };

  # Systemd services for Hyprland
  systemd.user.services = {
    # Polkit authentication agent
    polkit-kde-agent = {
      description = "polkit-kde-agent";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Enable GVfs for file manager functionality
  services.gvfs.enable = true;

  # Enable thumbnails
  services.tumbler.enable = true;

  # Configure Qt theming
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };
}

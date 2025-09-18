# NixOS-specific configuration
{ config, pkgs, ... }:

{
  # NixOS-specific packages (Linux-only)
  home.packages = with pkgs; [
    # Wayland/Hyprland ecosystem
    waybar             # Status bar
    wofi               # App launcher (wayland rofi)
    rofi-wayland       # Alternative launcher
    mako               # Notifications
    dunst              # Alternative notification daemon

    # Screenshot and screen recording
    grimblast          # Screenshots for Hyprland
    grim               # Wayland screenshot
    slurp              # Select area for screenshot
    wf-recorder        # Screen recording

    # System utilities
    swww               # Wallpaper daemon
    wl-clipboard       # Wayland clipboard utilities
    copyq              # Clipboard manager
    cliphist           # Clipboard history

    # Terminal emulators (Linux-native)
    alacritty          # GPU-accelerated terminal
    kitty              # Feature-rich terminal
    foot               # Lightweight Wayland terminal
    wezterm            # Modern terminal

    # File managers
    dolphin            # KDE file manager
    nautilus           # GNOME file manager
    thunar             # XFCE file manager
    pcmanfm            # Lightweight file manager

    # System monitoring
    btop               # Better htop
    nvtop              # GPU monitoring
    iotop              # I/O monitoring

    # Audio
    pavucontrol        # PulseAudio control
    playerctl          # Media player control

    # Development tools
    podman             # Container runtime
    podman-compose     # Docker-compose for podman
    distrobox          # Container-based development

    # Browsers and apps
    firefox            # Already in common, but ensuring it's here
    chromium           # Alternative browser
    bitwarden          # Password manager
    thunderbird        # Email client

    # Media
    mpv                # Video player
    vlc                # Alternative video player
    spotify            # Music streaming

    # Graphics and editing
    gimp               # Image editing
    inkscape           # Vector graphics
    krita              # Digital painting

    # Office
    libreoffice        # Office suite
    zathura            # PDF viewer
    evince             # Alternative PDF viewer

    # Communication
    discord            # Chat
    slack              # Work chat
    signal-desktop     # Secure messaging

    # Virtualization
    virt-manager       # VM management
    qemu               # Virtualization

    # Additional editors (GUI)
    zed-editor         # Modern code editor
    vscodium           # VS Code without telemetry
  ];

  # NixOS-specific shell configuration
  programs.zsh = {
    shellAliases = {
      # NixOS-specific aliases
      rebuild = "sudo nixos-rebuild switch --flake ~/dev/dotfiles#nixos";
      home-rebuild = "home-manager switch --flake ~/dev/dotfiles#jacob@nixos";

      # Update system
      update = "sudo nix flake update ~/dev/dotfiles && sudo nixos-rebuild switch --flake ~/dev/dotfiles#nixos";

      # Garbage collection
      clean = "sudo nix-collect-garbage -d && sudo nix-store --optimize";

      # System info
      sysinfo = "nix-shell -p nix-info --run 'nix-info -m'";
    };

    initExtra = ''
      # Wayland-specific environment variables
      if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        export MOZ_ENABLE_WAYLAND=1
        export QT_QPA_PLATFORM=wayland
        export SDL_VIDEODRIVER=wayland
        export _JAVA_AWT_WM_NONREPARENTING=1
      fi

      # Better font rendering
      export FREETYPE_PROPERTIES="cff:no-stem-darkening=0"
    '';
  };

  # Hyprland configuration
  home.file.".config/hypr/hyprland.conf".text = ''
    # Monitor configuration
    monitor=,preferred,auto,auto

    # Execute at launch
    exec-once = waybar
    exec-once = mako
    exec-once = swww init
    exec-once = copyq --start-server

    # Input configuration
    input {
        kb_layout = us
        follow_mouse = 1
        touchpad {
            natural_scroll = yes
            disable_while_typing = true
            tap-to-click = true
        }
        sensitivity = 0
    }

    # General configuration
    general {
        gaps_in = 5
        gaps_out = 10
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)
        layout = dwindle
    }

    # Decoration
    decoration {
        rounding = 10
        blur {
            enabled = true
            size = 3
            passes = 1
        }
        drop_shadow = yes
        shadow_range = 4
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)
    }

    # Animations
    animations {
        enabled = yes
        bezier = myBezier, 0.05, 0.9, 0.1, 1.05
        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
    }

    # Layout
    dwindle {
        pseudotile = yes
        preserve_split = yes
    }

    # Gestures
    gestures {
        workspace_swipe = on
    }

    # Keybindings
    $mainMod = SUPER

    # Applications
    bind = $mainMod, Return, exec, alacritty
    bind = $mainMod, B, exec, firefox
    bind = $mainMod, E, exec, dolphin
    bind = $mainMod, D, exec, wofi --show drun

    # Window management
    bind = $mainMod, Q, killactive,
    bind = $mainMod, M, exit,
    bind = $mainMod, F, fullscreen,
    bind = $mainMod, V, togglefloating,
    bind = $mainMod, P, pseudo,
    bind = $mainMod, J, togglesplit,

    # Focus movement
    bind = $mainMod, h, movefocus, l
    bind = $mainMod, l, movefocus, r
    bind = $mainMod, k, movefocus, u
    bind = $mainMod, j, movefocus, d

    # Window movement
    bind = $mainMod SHIFT, h, movewindow, l
    bind = $mainMod SHIFT, l, movewindow, r
    bind = $mainMod SHIFT, k, movewindow, u
    bind = $mainMod SHIFT, j, movewindow, d

    # Workspace switching
    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10

    # Move to workspace
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10

    # Mouse bindings
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow

    # Screenshot
    bind = , Print, exec, grimblast copy area
    bind = SHIFT, Print, exec, grimblast copy screen
  '';

  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "network" "cpu" "memory" "battery" "tray" ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };

        clock = {
          format = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = "CPU {usage}%";
          tooltip = false;
        };

        memory = {
          format = "MEM {}%";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-icons = ["" "" "" "" ""];
        };

        network = {
          format-wifi = " {essid}";
          format-ethernet = " {ipaddr}";
          format-disconnected = "⚠ Disconnected";
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrains Mono", "Font Awesome 6 Free";
        font-size: 13px;
      }

      window#waybar {
        background-color: rgba(43, 48, 59, 0.9);
        border-bottom: 3px solid rgba(100, 114, 125, 0.5);
        color: #ffffff;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ffffff;
        border-bottom: 3px solid transparent;
      }

      #workspaces button:hover {
        background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.active {
        background-color: #64727D;
        border-bottom: 3px solid #ffffff;
      }

      #clock, #battery, #cpu, #memory, #network {
        padding: 0 10px;
        color: #ffffff;
      }
    '';
  };

  # Mako notification daemon configuration
  services.mako = {
    enable = true;
    backgroundColor = "#2e3440";
    textColor = "#eceff4";
    borderColor = "#88c0d0";
    borderRadius = 5;
    borderSize = 2;
    defaultTimeout = 5000;
    font = "JetBrains Mono 10";

    extraConfig = ''
      [urgency=high]
      border-color=#bf616a
      default-timeout=0
    '';
  };

  # Additional NixOS-specific configurations
  home.file = {
    # Alacritty config
    ".config/alacritty/alacritty.yml".text = ''
      window:
        padding:
          x: 10
          y: 10
        opacity: 0.95

      font:
        normal:
          family: JetBrains Mono
        size: 12

      colors:
        primary:
          background: '#1e2127'
          foreground: '#abb2bf'
    '';

    # Wofi launcher config
    ".config/wofi/style.css".text = ''
      window {
        margin: 0px;
        border: 2px solid #88c0d0;
        background-color: #2e3440;
        border-radius: 10px;
      }

      #input {
        margin: 5px;
        border: none;
        color: #eceff4;
        background-color: #3b4252;
        border-radius: 5px;
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: #2e3440;
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: #2e3440;
      }

      #entry:selected {
        background-color: #88c0d0;
        color: #2e3440;
        border-radius: 5px;
      }
    '';
  };
}

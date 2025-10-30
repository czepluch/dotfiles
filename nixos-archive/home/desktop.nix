# Minimal Desktop Applications and Hyprland Configuration
# Only essential GUI apps and basic Hyprland setup
{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Catppuccin theme - global settings
  catppuccin = {
    enable = true;
    flavor = "mocha"; # Options: latte, frappe, macchiato, mocha
    accent = "mauve"; # Options: rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
  };

  # Cursor theme
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  # Minimal desktop applications
  home.packages = with pkgs; [
    # Browser
    firefox

    # File management
    nautilus # GNOME file manager (lighter than dolphin)

    # Media
    vlc
    mpv # Lightweight video player

    # System utilities
    pavucontrol
    gnome-calculator
    eog # Image viewer
    brightnessctl # Screen brightness control
    playerctl # Media player control

    # Hyprland essentials
    waybar
    wofi
    mako
    font-awesome # Icon fonts for waybar
    swww # Wallpaper daemon
    grimblast # Screenshots
    hyprlock # Hyprland's native screen locker
    hypridle
    hyprsunset # Screen color temperature adjustment (like redshift/f.lux)
    hyprpicker # Color picker utility
    hyprsysteminfo # System information utility
    hyprpolkitagent # Hyprland's polkit authentication agent
    wl-clipboard # Wayland clipboard utilities
    cliphist # Clipboard history manager

    # Code
    # Note: These packages auto-update from nixpkgs-unstable
    # Run 'nix flake update' periodically to get latest versions
    zed-editor # Latest: check with 'nix eval nixpkgs#zed-editor.version'
    claude-code
    bitwarden-desktop

    # Terminal
    kitty # Alternative GPU-accelerated terminal
    warp-terminal # Latest: check with 'nix eval nixpkgs#warp-terminal.version'
  ];

  # Basic Firefox configuration
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      isDefault = true;
      name = "default";

      extensions.force = true; # Allow Catppuccin module to manage extensions

      settings = {
        "privacy.trackingprotection.enabled" = true;
        "browser.startup.homepage" = "about:home";
        "browser.newtabpage.enabled" = false;
        "gfx.webrender.all" = true;
        "widget.dmabuf.force-enabled" = true;
      };
    };
  };

  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    settings = {
      # Environment variables for scaling
      env = [
        "XCURSOR_SIZE,24"
        "GDK_SCALE,1.5"
        "GDK_DPI_SCALE,1"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland" # Force Electron apps to use Wayland for proper scaling
      ];
      # Performance optimizations
      debug = {
        disable_logs = true;
        damage_tracking = 2; # Full damage tracking for better performance
      };

      misc = {
        force_default_wallpaper = 0; # Disable anime wallpaper
        vfr = true; # Variable frame rate
        vrr = 0; # Disable VRR
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
      # Monitor configuration
      monitor = [
        # 1.5 fractional scaling - good balance for 14" 2880x1800 display
        "eDP-1,2880x1800@60,0x0,1.5"
      ];

      # Input configuration
      input = {
        kb_layout = "us,dk";
        kb_options = "grp:ctrl_space_toggle,caps:escape";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true; # Mac-style scrolling
          disable_while_typing = true;
        };
        sensitivity = 0;
      };

      # General settings
      general = {
        gaps_in = 3;
        gaps_out = 6;
        border_size = 2;
        "col.active_border" = "rgba(cba6f7ee)";
        "col.inactive_border" = "rgba(585b70aa)";
        layout = "dwindle";
      };

      # XWayland settings - fixes blurry/pixelated apps
      xwayland = {
        force_zero_scaling = true;
      };

      # Cursor settings
      cursor = {
        no_warps = true; # Prevent cursor warping
      };

      # Decoration - reduced for performance
      decoration = {
        rounding = 5;
        blur = {
          enabled = false; # Disable blur for major CPU savings
          size = 3;
          passes = 1;
        };
      };

      # Animations - simplified for performance
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 3, myBezier" # Faster animations
          "windowsOut, 1, 3, default, popin 80%"
          "border, 1, 5, default"
          "fade, 1, 3, default"
          "workspaces, 1, 3, default"
        ];
      };

      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Window rules
      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        "float,class:^(blueman-manager)$"
        "float,class:^(Calculator)$"
        "float,class:^(firefox)$,title:^(Picture-in-Picture)$"
        "pin,class:^(firefox)$,title:^(Picture-in-Picture)$"
        # Disable opacity for performance
        # "opacity 0.9,class:^(Alacritty)$"

        # Fix blurry text for specific apps
        "forcergbx,class:^(dev.warp.Warp)$"
        "forcergbx,class:^(Bitwarden)$"
        "rounding 0,class:^(dev.warp.Warp)$" # Disable rounding for sharper text
        "rounding 0,class:^(Bitwarden)$"
        "noblur,class:^(dev.warp.Warp)$"
        "noshadow,class:^(dev.warp.Warp)$"
        "xray 0,class:^(dev.warp.Warp)$" # Disable transparency
      ];

      # Key bindings
      "$mod" = "SUPER";

      bind = [
        # Applications
        "$mod, Return, exec, alacritty"
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, E, exec, thunar"
        "$mod, V, togglefloating"
        "$mod, D, exec, wofi --show drun"
        "$mod, W, exec, wofi --show window"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"

        # Move focus with vim keys
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Resize windows with arrow keys
        "$mod, left, resizeactive, -80 0"
        "$mod, right, resizeactive, 80 0"
        "$mod, up, resizeactive, 0 -80"
        "$mod, down, resizeactive, 0 80"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move windows to workspaces
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Special workspace (scratchpad)
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        # Workspace navigation
        "$mod, TAB, workspace, e+1"
        "$mod SHIFT, TAB, workspace, e-1"

        # Screenshots - Mac-like (copy + save)
        ", Print, exec, grimblast --notify copysave area"
        "$mod, Print, exec, grimblast --notify copysave screen"
        "$mod SHIFT, Print, exec, grimblast --notify save area" # Save only (no copy)

        # Media keys
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        # Brightness (if laptop)
        ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"

        # Night light (blue light filter)
        "$mod SHIFT, N, exec, pkill hyprsunset || hyprsunset -t 3400" # Toggle night mode

        # Clipboard history
        "$mod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy" # Show clipboard history

        # Color picker
        "$mod SHIFT, C, exec, hyprpicker -a" # Pick color and copy to clipboard
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Startup applications
      exec-once = [
        "waybar"
        "mako"
        "swww-daemon"
        "hyprpolkitagent"
        "hyprsunset -t 4500" # Start with warm color temp (toggle with Super+Shift+N)
        "[workspace special:magic silent] alacritty"
        "hypridle"
        "wl-paste --type text --watch cliphist store" # Clipboard history for text
        "wl-paste --type image --watch cliphist store" # Clipboard history for images
      ];
    };
  };

  # Waybar configuration - minimal
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 40;

        modules-left = ["hyprland/workspaces"];
        modules-center = ["hyprland/window"];
        modules-right = ["hyprland/language" "pulseaudio" "backlight" "network" "cpu" "memory" "temperature" "battery" "clock" "tray"];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "󰈹"; # Browser/Web
            "2" = "󰅩"; # Code/Development
            "3" = "󰇰"; # Email/Communication
            "4" = "󰝚"; # Music/Media
            "5" = "󰉋"; # Files/Documents
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            "default" = "󰋜";
          };
          disable-scroll = true;
          all-outputs = true;
          on-click = "activate";
          persistent-workspaces = {
            "*" = 5; # Show 5 workspaces on all monitors
          };
        };

        "hyprland/window" = {
          max-length = 50;
        };

        "hyprland/language" = {
          format = "󰌌 {}";
          format-en = "us";
          format-da = "dk";
          tooltip = false;
          on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
        };

        clock = {
          format = "󰥔 {:%H:%M}";
          format-alt = "󰃭 {:%A, %B %d, %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            format = {
              months = "<span color='#f5c2e7'><b>{}</b></span>";
              days = "<span color='#cdd6f4'><b>{}</b></span>";
              today = "<span color='#cba6f7'><b><u>{}</u></b></span>";
            };
          };
        };

        cpu = {
          format = "󰻠 {usage}%";
          interval = 2;
          tooltip = true;
        };

        memory = {
          format = "󰍛 {}%";
          format-alt = "󰍛 {used:0.1f}G/{total:0.1f}G";
          interval = 2;
          tooltip = true;
          tooltip-format = "Memory: {used:0.1f}GiB / {total:0.1f}GiB\nSwap: {swapUsed:0.1f}GiB / {swapTotal:0.1f}GiB";
        };

        battery = {
          states = {
            good = 80;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          format-full = "󰁹 Full";
          format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽"];
          interval = 10;
          tooltip = true;
          tooltip-format = "Battery: {capacity}%\n{timeTo}";
        };

        network = {
          format-wifi = "󰤨 {signalStrength}%";
          format-ethernet = "󰈀 Connected";
          format-linked = "󰈀 (No IP)";
          format-disconnected = "󰤭 Disconnected";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          tooltip = true;
          tooltip-format = "Interface: {ifname}\nSSID: {essid}\nIP: {ipaddr}\nSignal: {signalStrength}%\n↓ {bandwidthDownBits} ↑ {bandwidthUpBits}";
          interval = 5;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}% 󰂯";
          format-bluetooth-muted = "󰝟 󰂯";
          format-muted = "󰝟";
          format-icons = {
            headphone = "󰋋";
            hands-free = "󰋎";
            headset = "󰋎";
            phone = "󰏲";
            portable = "󰜟";
            car = "󰄋";
            default = ["󰕿" "󰖀" "󰕾"];
          };
          tooltip = true;
          tooltip-format = "Volume: {volume}%\n{desc}";
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          scroll-step = 5;
        };

        backlight = {
          format = "󰃞 {percent}%";
          tooltip = true;
          on-scroll-up = "brightnessctl s 5%+";
          on-scroll-down = "brightnessctl s 5%-";
        };

        temperature = {
          thermal-zone = 2;
          # hwmon-path removed - let waybar auto-detect for stability across reboots/kernel updates
          critical-threshold = 80;
          format = "󰔏 {temperatureC}°C";
          format-critical = "󰸁 {temperatureC}°C";
          tooltip = true;
        };

        tray = {
          icon-size = 16;
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 15px;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(30, 30, 46, 0.9);
        border-bottom: 3px solid rgba(116, 199, 236, 0.8);  /* Sapphire blue for distinction */
        color: #cdd6f4;
      }

      #workspaces button {
        padding: 0 5px;
        color: #cdd6f4;
      }

      #workspaces button.active {
        background-color: rgba(116, 199, 236, 0.8);
        color: #1e1e2e;
      }

      #language {
        padding: 0 8px;
        margin: 0 4px;
        color: #f5c2e7;
        font-weight: bold;
        background-color: rgba(203, 166, 247, 0.1);
        border-radius: 5px;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #backlight,
      #temperature,
      #tray {
        padding: 0 8px;
        margin: 0 2px;
        color: #cdd6f4;
        border-radius: 5px;
      }

      #window {
        color: #a6adc8;
        font-weight: bold;
      }

      #workspaces button {
        padding: 0 8px;
        margin: 0 2px;
        border-radius: 5px;
      }

      #workspaces button:hover {
        background: rgba(203, 166, 247, 0.2);
      }

      #pulseaudio {
        color: #89b4fa;
        background-color: rgba(137, 180, 250, 0.1);
      }

      #network {
        color: #94e2d5;
        background-color: rgba(148, 226, 213, 0.1);
      }

      #cpu {
        color: #f9e2af;
        background-color: rgba(249, 226, 175, 0.1);
      }

      #memory {
        color: #eba0ac;
        background-color: rgba(235, 160, 172, 0.1);
      }

      #temperature {
        color: #f38ba8;
        background-color: rgba(243, 139, 168, 0.1);
      }

      #temperature.critical {
        animation: blink 0.5s linear infinite alternate;
      }

      #backlight {
        color: #fab387;
        background-color: rgba(250, 179, 135, 0.1);
      }

      #battery {
        color: #a6e3a1;
        background-color: rgba(166, 227, 161, 0.1);
      }

      #battery.charging, #battery.plugged {
        color: #94e2d5;
        background-color: rgba(148, 226, 213, 0.1);
      }

      #battery.warning:not(.charging) {
        color: #fab387;
        background-color: rgba(250, 179, 135, 0.2);
      }

      #battery.critical:not(.charging) {
        background-color: #f38ba8;
        color: #1e1e2e;
        animation: blink 0.5s linear infinite alternate;
      }

      #clock {
        color: #cba6f7;
        background-color: rgba(203, 166, 247, 0.1);
        font-weight: bold;
      }

      #tray {
        background-color: rgba(49, 50, 68, 0.6);
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #f38ba8;
      }

      @keyframes blink {
        to {
          background-color: #f38ba8;
          color: #1e1e2e;
        }
      }
    '';
  };

  # Zed Editor - Settings symlinked to dotfiles
  # Zed is installed via package (see home.packages above)
  # Settings file is symlinked from config/zed/settings.json
  # Changes in Zed will be reflected in the dotfiles repo
  xdg.configFile."zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/zed/settings.json";

  # GNOME Keyring - for storing credentials
  services.gnome-keyring = {
    enable = true;
    components = ["secrets"];
  };

  # Notification daemon
  services.mako.settings = {
    enable = true;
    backgroundColor = "#1e1e2e";
    borderColor = "#cba6f7";
    borderRadius = 8;
    borderSize = 2;
    textColor = "#cdd6f4";
    font = "JetBrainsMono Nerd Font 11";
    defaultTimeout = 5000;
  };

  # Screen locker - Hyprlock (Hyprland native)
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        grace = 0;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          position = "0, -80";
          monitor = ""; # Empty string = all monitors (shows on focused/primary)
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(cdd6f4)";
          inner_color = "rgb(1e1e2e)";
          outer_color = "rgb(cba6f7)";
          outline_thickness = 2;
          placeholder_text = "<span foreground=\"##a6adc8\">Password...</span>";
          shadow_passes = 2;
        }
      ];

      label = [
        {
          # Time
          monitor = ""; # Empty string = all monitors
          text = "cmd[update:1000] echo \"<b><big> $(date +\"%H:%M:%S\") </big></b>\"";
          color = "rgb(cdd6f4)";
          font_size = 64;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 150";
          halign = "center";
          valign = "center";
        }
        {
          # Date
          monitor = ""; # Empty string = all monitors
          text = "cmd[update:1000] echo \"<b> $(date +\"%A, %B %d\") </b>\"";
          color = "rgb(a6adc8)";
          font_size = 24;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 50";
          halign = "center";
          valign = "center";
        }
        {
          # User
          monitor = ""; # Empty string = all monitors
          text = "  $USER";
          color = "rgb(cba6f7)";
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # Wofi launcher configuration
  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
      hide_scroll = true;
    };

    style = ''
      window {
        margin: 0px;
        border: 2px solid #cba6f7;
        border-radius: 8px;
        background-color: rgba(30, 30, 46, 0.95);
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      #input {
        margin: 5px;
        border: none;
        color: #cdd6f4;
        background-color: rgba(49, 50, 68, 0.9);
        border-radius: 5px;
        padding: 10px;
      }

      #input::placeholder {
        color: #6c7086;
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: transparent;
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: transparent;
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: #cdd6f4;
      }

      #text:selected {
        color: #1e1e2e;
        background-color: #cba6f7;
        border-radius: 5px;
      }

      #entry {
        padding: 10px;
        border-radius: 5px;
        background-color: transparent;
      }

      #entry:selected {
        background-color: rgba(203, 166, 247, 0.3);
        border-radius: 5px;
      }
    '';
  };

  # Idle daemon
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "pidof hyprlock || hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        lock_cmd = "pidof hyprlock || hyprlock"; # Avoid multiple instances
      };

      listener = [
        {
          timeout = 30;
          on-timeout = "brightnessctl -s set 10%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 120;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 150;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          # Suspend after 10 minutes of inactivity (only on battery)
          timeout = 600;
          on-timeout = "if cat /sys/class/power_supply/BAT*/status | grep -q Discharging; then systemctl suspend; fi";
        }
      ];
    };
  };
}

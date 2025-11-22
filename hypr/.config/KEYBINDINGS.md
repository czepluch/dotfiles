# Hyprland Custom Keybindings

This document lists all custom keybindings configured for this Hyprland setup.

**Note:** `$mainMod` = `SUPER` (Windows/Command key)

---

## Universal Clipboard (Omarchy-style)

Uses Insert-based shortcuts that work everywhere including terminals!

| Keybinding | Action | Description |
|------------|--------|-------------|
| `SUPER + C` | Copy | Universal copy (sends Ctrl+Insert) |
| `SUPER + V` | Paste | Universal paste (sends Shift+Insert) |
| `SUPER + X` | Cut | Universal cut (sends Ctrl+X) |
| `SUPER + Ctrl + V` | Clipboard History | Opens clipboard manager with fuzzel |

---

## Window Management

| Keybinding | Action | Description |
|------------|--------|-------------|
| `SUPER + Return` | Launch Terminal | Opens kitty terminal |
| `SUPER + Q` | Kill Active | Close focused window |
| `SUPER + M` | Exit Hyprland | Exit/logout |
| `SUPER + F` | Toggle Floating | Toggle window floating mode |
| `SUPER + P` | Pseudo Tile | Dwindle pseudo-tiling |
| `SUPER + J` | Toggle Split | Toggle split direction |

---

## Application Launchers

| Keybinding | Action | Description |
|------------|--------|-------------|
| `SUPER + E` | File Manager | Opens dolphin |
| `SUPER + R` | App Launcher | Opens wofi |
| `SUPER + D` | App Launcher | Opens fuzzel |

---

## Focus Movement

| Keybinding | Action | Description |
|------------|--------|-------------|
| `SUPER + Left` | Focus Left | Move focus to left window |
| `SUPER + Right` | Focus Right | Move focus to right window |
| `SUPER + Up` | Focus Up | Move focus to window above |
| `SUPER + Down` | Focus Down | Move focus to window below |

---

## Workspace Management

| Keybinding | Action | Description |
|------------|--------|-------------|
| `SUPER + 1-9, 0` | Switch Workspace | Switch to workspace 1-10 |
| `SUPER + Shift + 1-9, 0` | Move to Workspace | Move window to workspace 1-10 |
| `SUPER + S` | Special Workspace | Toggle special workspace "magic" |
| `SUPER + Shift + S` | Move to Special | Move window to special workspace |
| `SUPER + Mouse_Down` | Next Workspace | Scroll to next workspace |
| `SUPER + Mouse_Up` | Previous Workspace | Scroll to previous workspace |

---

## Window Manipulation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `SUPER + LMB (drag)` | Move Window | Move floating window |
| `SUPER + RMB (drag)` | Resize Window | Resize floating window |

---

## Screenshots

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Print` | Region Screenshot | Select area, save to ~/pics/scrots/ + clipboard |
| `Shift + Print` | Full Screenshot | Full screen, save + clipboard |
| `Alt + Print` | Window Screenshot | Active window, save + clipboard |

**Screenshot location:** `~/pics/scrots/`
**Filename format:** `YYYY-MM-DD_HH-MM-SS.png`

---

## Multimedia Keys

### Audio Control

| Keybinding | Action | Description |
|------------|--------|-------------|
| `XF86AudioRaiseVolume` | Volume Up | Increase volume by 5% |
| `XF86AudioLowerVolume` | Volume Down | Decrease volume by 5% |
| `XF86AudioMute` | Mute Audio | Toggle audio mute |
| `XF86AudioMicMute` | Mute Mic | Toggle microphone mute |

### Media Playback (requires playerctl)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `XF86AudioNext` | Next Track | Skip to next track |
| `XF86AudioPause` | Play/Pause | Toggle playback |
| `XF86AudioPlay` | Play/Pause | Toggle playback |
| `XF86AudioPrev` | Previous Track | Skip to previous track |

### Brightness Control

| Keybinding | Action | Description |
|------------|--------|-------------|
| `XF86MonBrightnessUp` | Brightness Up | Increase screen brightness by 5% |
| `XF86MonBrightnessDown` | Brightness Down | Decrease screen brightness by 5% |

---

## Terminal-Specific (Kitty)

These are the standard terminal shortcuts:

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl + Shift + C` | Copy | Copy in terminal (traditional) |
| `Ctrl + Shift + V` | Paste | Paste in terminal (traditional) |
| `Ctrl + Shift + F5` | Reload Config | Reload kitty configuration |

**Note:** With universal clipboard enabled, `SUPER+C/V` also works in terminal!

---

## Query Current Keybindings

To see all active keybindings in Hyprland:
```bash
hyprctl binds
```

To reload Hyprland configuration:
```bash
hyprctl reload
```

---

*Last updated: 2025-11-10*

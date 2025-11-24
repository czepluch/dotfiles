# Fuzzel Configuration

**Status:** Unstowed (not currently active)

This fuzzel configuration is kept for reference but not currently stowed. We're using **hyprlauncher** instead, which integrates with the Hyprland ecosystem and uses hyprtoolkit for theming.

## To switch back to fuzzel:

```bash
cd ~/dotfiles
stow fuzzel
```

Then update the keybindings in `hypr/.config/hypr/hyprland.conf`:
- Replace `hyprlauncher` with `fuzzel` on line ~251
- Replace `hyprlauncher --dmenu` with `fuzzel --dmenu` on line ~261

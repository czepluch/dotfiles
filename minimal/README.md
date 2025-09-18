# Minimal NixOS Configuration

A simple, working NixOS setup perfect for getting started. This configuration gets you:

- 🖥️ **Hyprland** (Wayland window manager)  
- 🔧 **Zed & Warp** (modern editor & terminal)
- 🌐 **Firefox** with basic privacy settings
- 📝 **Essential CLI tools** (eza, ripgrep, bat, etc.)
- 🔒 **Bitwarden** password manager

## 🚀 Quick Start

### 1. Install NixOS
Follow the [official NixOS installation guide](https://nixos.org/manual/nixos/stable/#sec-installation) first.

### 2. Clone and Setup
```bash
# Clone this repo
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles/minimal

# Copy your hardware configuration
sudo cp /etc/nixos/hardware-configuration.nix .

# Update git config with your details
nano home.nix  # Change "Your Name" and email
```

### 3. Apply Configuration
```bash
# Apply system configuration
sudo nixos-rebuild switch --flake .#laptop

# Install Home Manager (first time only)
nix run nixpkgs#home-manager -- switch --flake .#dev@laptop
```

### 4. Setup Your Apps
After reboot, you'll have empty config directories ready for your settings:
```bash
~/.config/zed/     # Paste your Zed settings here
~/.config/warp/    # Paste your Warp settings here  
~/.config/hypr/    # Create hyprland.conf here
~/.config/waybar/  # Create waybar config here
```

## 🎯 Basic Usage

### Daily Commands
```bash
# Rebuild system after changes
rebuild

# Rebuild user config after changes  
home-rebuild

# Update everything
nix flake update && rebuild && home-rebuild
```

### Key Bindings (Default Hyprland)
- `Super + T` → Terminal (Warp)
- `Super + R` → App launcher (wofi)
- `Super + Q` → Close window
- `Super + E` → File manager
- `Ctrl + Space` → Switch keyboard layout (US ↔ DK)

## 📝 What's Included

### System Level (`system.nix`)
- Hyprland window manager
- Audio (PipeWire)
- Bluetooth support
- AMD graphics drivers
- Network management

### User Level (`home.nix`)
- **Editor**: Zed (primary), Neovim (quick edits)
- **Terminal**: Warp (primary), Alacritty (backup)
- **Browser**: Firefox with privacy settings
- **CLI Tools**: eza, ripgrep, fd, bat, fzf, htop
- **Apps**: Bitwarden, Dolphin file manager

## 🔧 Customization

### Adding Packages
Edit `home.nix` and add to the `packages` list:
```nix
home.packages = with pkgs; [
  # ... existing packages ...
  discord
  obsidian
];
```

### System Changes
Edit `system.nix` for system-wide changes like:
- Hardware drivers
- System services  
- Boot configuration

### App Configurations
Just edit files in `~/.config/` normally - no rebuilds needed!

## 🆙 Next Steps

Once comfortable with this minimal setup:

1. **Copy configs** from online (r/unixporn, GitHub dotfiles)
2. **Add more packages** as needed
3. **Consider the full setup** in `../full/` for advanced features

## 📚 Learning Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)

## 🐛 Troubleshooting

### Common Issues
```bash
# If something breaks, rollback
sudo nixos-rebuild switch --rollback

# Check for errors
sudo journalctl -xe

# Rebuild without switching (test first)
sudo nixos-rebuild dry-build --flake .#laptop
```

### Getting Help
- Check logs: `journalctl -xe`
- NixOS Discourse: https://discourse.nixos.org/
- Reddit: r/NixOS

---

**This is a starting point!** Feel free to modify anything to match your preferences. The goal is to learn NixOS basics before moving to more complex configurations.
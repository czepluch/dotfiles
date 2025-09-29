# NixOS Starter 🚀

**A great first-time NixOS configuration** - batteries included, fully declarative, ready to customize.

This configuration consolidates the best practices from minimal and advanced NixOS setups into one cohesive, beginner-friendly starting point. It uses the **full Nix way** for complete reproducibility, with easy fallback options if you want to manage some configs manually later.

## ✨ Features

### 🎯 **Beginner-Friendly Design**
- **Single configuration** instead of choosing between minimal/full
- **Progressive complexity** - start simple, add features as you learn
- **Self-documenting** - every setting has clear comments
- **Modern best practices** - latest Nix features and patterns

### 🖥️ **Complete Desktop Environment**
- **Hyprland** - Modern Wayland compositor with full declarative config
- **VS Code** - Pre-configured with useful extensions
- **Firefox** - Privacy-focused settings and extension support
- **Waybar** - Beautiful status bar with system monitoring
- **Full screenshot/screencast** support

### 🛠️ **Development Ready**
- **Multiple language support** - Python, Rust, Go, Node.js, etc.
- **Container support** - Docker/Podman pre-configured
- **Git workflow** - Advanced aliases and hooks
- **Terminal tools** - Modern CLI replacements (eza, ripgrep, bat, etc.)
- **Database support** - PostgreSQL, Redis, SQLite

### 📦 **User Profiles**
Choose your experience level:
- **`developer.nix`** - Full development environment (default)
- **`minimal.nix`** - Essential apps only
- **`creative.nix`** - Media editing and creative tools (coming soon)

### 🔧 **Smart Configuration Management**
- **Full Nix way** - Everything declared in `.nix` files for reproducibility
- **Easy fallback** - Commented sections to switch to hybrid mode
- **Hardware detection** - Automatic optimizations for your system
- **Cross-platform** - Works on any NixOS system

## 🚀 Quick Start

### 1. **Installation** (Fresh NixOS)

```bash
# Clone this configuration
git clone https://github.com/yourusername/nixos-starter.git
cd nixos-starter

# Copy your hardware configuration
sudo cp /etc/nixos/hardware-configuration.nix .

# Customize your settings
vim flake.nix  # Edit the userConfig section

# Install
nix develop  # Enter development shell
just install  # Install everything
```

### 2. **Daily Usage**

```bash
# System changes (after editing system/*.nix)
just rebuild

# User changes (after editing home/*.nix)
just home-rebuild

# Update everything
just update-rebuild

# Clean old generations
just clean

# See all commands
just help
```

### 3. **Customization**

**Edit these files to customize your setup:**

- **`flake.nix`** - User info, hostname, enabled modules
- **`system/core.nix`** - System settings, hardware, networking
- **`system/desktop.nix`** - Desktop environment configuration
- **`home/desktop.nix`** - GUI applications, Hyprland config
- **`home/profiles/`** - Choose or customize your profile

## 📋 What's Included

### 🏠 **Home Applications**
```
Essential:           Development:        Media:
- Firefox            - VS Code           - VLC
- Alacritty          - Git + GitHub CLI  - Spotify
- Dolphin (Files)    - Docker/Podman     - Screenshots
- Calculator         - Multiple languages- Screen recording
- Archives           - Database tools

Terminal Tools:      System:             Optional:
- eza (better ls)    - Waybar            - Discord
- ripgrep            - Mako (notifications) - Slack
- bat (better cat)   - Hyprland          - Gaming tools
- fzf (fuzzy find)   - Audio/Bluetooth   - Creative apps
```

### ⚙️ **System Configuration**
- **Modern kernel** - Latest for best hardware support
- **Wayland native** - Future-proof graphics stack
- **PipeWire audio** - Low latency, professional audio
- **NetworkManager** - Easy network management
- **Bluetooth** - Full desktop Bluetooth support
- **Printing** - CUPS with network printer discovery
- **Flatpak support** - Access to additional applications

## 🎛️ Configuration Philosophy

### **Full Nix Way (Default)**
Everything is declared in `.nix` files:
- ✅ **Complete reproducibility** - Same config = same system
- ✅ **Version control** - Track all changes in git
- ✅ **Rollback capability** - Easy to undo changes
- ✅ **Documentation** - Configuration is self-documenting

Example: Hyprland is fully configured in `home/desktop.nix`

### **Hybrid Mode (Optional)**
Switch to manual config editing for specific applications:

```nix
# In home/desktop.nix - uncomment the extraConfig section
wayland.windowManager.hyprland = {
  enable = true;
  # settings = { ... };  # Comment out full config

  extraConfig = ''
    # Minimal config - edit ~/.config/hypr/hyprland.conf manually
    $mod = SUPER
    bind = $mod, Return, exec, alacritty
    # ...
  '';
};
```

This gives you the flexibility to use GUI configuration tools while keeping the system reproducible.

## 🔧 Advanced Usage

### **Adding New Applications**

1. **System-wide apps** → `system/core.nix` or `system/optional/`
2. **User apps** → `home/default.nix` or `home/profiles/`
3. **Desktop apps** → `home/desktop.nix`

### **Creating Custom Modules**

```nix
# system/optional/gaming.nix
{ config, pkgs, ... }: {
  programs.steam.enable = true;
  hardware.opengl.driSupport32Bit = true;

  environment.systemPackages = with pkgs; [
    lutris
    discord
    obs-studio
  ];
}
```

Then enable in `flake.nix`:
```nix
./system/optional/gaming.nix  # Uncomment this line
```

### **Hardware Optimizations**

Uncomment in `flake.nix` based on your hardware:
```nix
# nixos-hardware.nixosModules.common-gpu-amd      # AMD Graphics
# nixos-hardware.nixosModules.common-gpu-nvidia   # NVIDIA Graphics
# nixos-hardware.nixosModules.common-cpu-amd      # AMD CPU
# nixos-hardware.nixosModules.common-cpu-intel    # Intel CPU
```

### **Managing Secrets**

For sensitive configuration (WiFi passwords, API keys, etc.):

1. **Option A**: Use `sops-nix` (included in inputs)
2. **Option B**: Keep secrets in separate untracked files
3. **Option C**: Use environment variables

## 🔍 Troubleshooting

### **Common Issues**

**Build failures:**
```bash
just check        # Check configuration syntax
nix flake check   # Validate flake
```

**Permission issues:**
```bash
sudo chown -R $USER:$USER ~/.config  # Fix ownership
```

**Rollback changes:**
```bash
just boot-rollback  # Boot previous generation
# Or select older generation at boot
```

**Clean rebuild:**
```bash
just clean        # Remove old generations
just rebuild      # Fresh build
```

### **Getting Help**

- 📚 **NixOS Manual**: https://nixos.org/manual/
- 💬 **NixOS Discourse**: https://discourse.nixos.org/
- 🗨️ **Reddit**: r/NixOS
- 📖 **This Config**: Check comments in `.nix` files

## 🤝 Contributing

This configuration is designed to be a great starting point. Contributions welcome!

**Areas for improvement:**
- Additional hardware support
- More user profiles (creative, gaming, etc.)
- Better documentation
- Additional optional modules

## 📄 License

MIT License - Use this configuration however you'd like!

## 🙏 Credits

Built on the shoulders of:
- **NixOS** - The incredible Linux distribution
- **Home Manager** - Declarative user environment management
- **Hyprland** - Amazing Wayland compositor
- **Community** - Countless helpful community members

---

**Happy NixOS-ing!** 🎉

*Remember: The best NixOS configuration is the one you understand and can maintain yourself.*
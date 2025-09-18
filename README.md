# NixOS Dotfiles - Choose Your Adventure

This repository contains two NixOS configurations to suit different needs and experience levels.

## 🌱 Minimal Setup - Start Here!

**Perfect for**: NixOS beginners, getting started quickly, learning the basics

```
minimal/
├── flake.nix              # Simple flake (34 lines)
├── system.nix             # Essential system config (104 lines)  
├── home.nix               # Basic user setup (118 lines)
├── hardware-configuration.nix
└── README.md              # Step-by-step guide
```

**What you get:**
- ✅ Hyprland with basic setup
- ✅ Zed editor & Warp terminal  
- ✅ Firefox, Bitwarden
- ✅ Essential CLI tools (eza, ripgrep, bat, fzf)
- ✅ Regular `~/.config` - edit configs directly
- ✅ ~260 lines total - easy to understand

**Quick start:**
```bash
cd minimal/
sudo nixos-rebuild switch --flake .#laptop
nix run nixpkgs#home-manager -- switch --flake .#dev@laptop
```

## 🚀 Full Setup - Advanced Features

**Perfect for**: Experienced users, maximum functionality, reproducible configs

```
full/
├── flake.nix              # Feature-rich flake with overlays
├── nix/                   # Modular structure
│   ├── hosts/             # Multiple host support
│   ├── home/              # User configurations  
│   ├── modules/           # Reusable components
│   └── packages/          # Custom packages
├── config/                # Managed dotfiles
├── scripts/               # Automation tools
└── Makefile               # Common commands
```

**What you get:**
- ✅ Everything from minimal +
- ✅ Modular, reusable configuration
- ✅ Custom packages (Cursor, Warp AppImages)
- ✅ Home Manager managed configs
- ✅ Multiple host/user support
- ✅ Advanced automation scripts
- ✅ Full reproducibility

## 🎯 Which Should You Choose?

### Choose **Minimal** if you:
- 🔰 Are new to NixOS
- 🚀 Want to get started quickly  
- 📖 Want to learn NixOS incrementally
- ⚡ Prefer editing configs directly
- 🎮 Want to experiment freely

### Choose **Full** if you:
- 🧠 Are comfortable with Nix concepts
- 🏗️ Want maximum reproducibility
- 🔄 Manage multiple machines
- 📦 Need custom packages
- 🎯 Want a complete, production-ready setup

## 🔄 Migration Path

**Recommended learning journey:**

1. **Start with minimal** - Get NixOS working and familiar
2. **Customize freely** - Add configs, try different apps
3. **Learn the concepts** - Understand flakes, modules, Home Manager
4. **Graduate to full** - When you want reproducible, managed configs

You can always copy features from full setup into minimal as you learn!

## 🛠️ Common Commands

### Minimal Setup
```bash
# System rebuild
sudo nixos-rebuild switch --flake ~/dotfiles/minimal#laptop

# User rebuild  
home-manager switch --flake ~/dotfiles/minimal#dev@laptop
```

### Full Setup
```bash
# Use the included Makefile
cd full/
make rebuild      # System rebuild
make home-rebuild # User rebuild
make help         # See all commands
```

## 📚 Getting Started

1. **Choose your setup** (minimal recommended for beginners)
2. **Follow the README** in your chosen directory
3. **Join the community** - r/NixOS, NixOS Discourse
4. **Experiment and learn** - NixOS makes it safe to try things!

## 🤝 Philosophy

- **Minimal**: Learn by doing, iterate quickly
- **Full**: Declare everything, reproduce everywhere

Both approaches are valid - pick what matches your current needs and experience level!

---

**Happy NixOS-ing!** 🎉 Choose your path and start building your perfect development environment.
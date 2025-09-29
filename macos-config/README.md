# macOS Home Manager Configuration 🍎

This is a standalone Home Manager configuration for macOS.

## 🚀 Quick Start

```bash
cd macos-config/

# Install Home Manager if not already installed
nix run home-manager/master -- init --switch

# Apply this configuration
home-manager switch --flake .#jacob@macos

# Or enter dev shell first
nix develop
home-manager switch --flake .#jacob@macos
```

## ⚙️ Configuration Files

- **`flake.nix`** - Main configuration with user settings
- **`home/common.nix`** - Base configuration
- **`home/macos.nix`** - macOS-specific packages and settings

## 🔧 Customization

Edit the user settings in `flake.nix`:

```nix
# User settings (customize these)
username = "jacob";              # ← Your username
gitName = "Jacob Czepluch";      # ← Your name
gitEmail = "j.czepluch@proton.me"; # ← Your email
```

## 📋 Available Configuration

- **`jacob@macos`** - macOS Home Manager setup

## 🔄 Daily Usage

```bash
# Update and rebuild
nix flake update
home-manager switch --flake .#jacob@macos

# Check configuration
nix flake check

# Or use just commands
just switch
just update
```

## 📁 Relationship to NixOS Starter

This is a **separate configuration** from the main NixOS Starter in the parent directory:

- **`../`** - NixOS Starter (pure NixOS focus)
- **`./`** - macOS Home Manager (pure macOS focus)

Both can coexist and serve different purposes!
# NixOS Starter - Command Runner
# Use 'just <command>' to run these commands

# Default recipe (shows help)
default:
    @just --list

# System management
rebuild:
    sudo nixos-rebuild switch --flake .

rebuild-test:
    sudo nixos-rebuild test --flake .

home-rebuild:
    home-manager switch --flake .

# Full system update and rebuild
update-rebuild:
    nix flake update
    sudo nixos-rebuild switch --flake .
    home-manager switch --flake .

# Update flake inputs
update:
    nix flake update

# Clean old generations (keep last 5)
clean:
    sudo nix-collect-garbage -d --delete-older-than 7d
    nix-collect-garbage -d --delete-older-than 7d

# Development
check:
    nix flake check

fmt:
    nix fmt

lint:
    statix check .
    deadnix .

# Show system info
info:
    nix-shell -p nix-info --run "nix-info -m"

# Show flake info
flake-info:
    nix flake show

# Enter development shell
dev:
    nix develop

# Boot configuration
boot-list:
    sudo /run/current-system/bin/switch-to-configuration --list-generations

boot-rollback:
    sudo nixos-rebuild switch --rollback

# Hardware info (run before installation)
hardware-scan:
    sudo nixos-generate-config --show-hardware-config

# Installation helpers
install-setup:
    @echo "🚀 NixOS Starter Installation Setup"
    @echo "1. First, copy your hardware-configuration.nix from /etc/nixos/"
    @echo "2. Edit userConfig in flake.nix with your details"
    @echo "3. Run: just install"

install:
    @echo "🔧 Installing NixOS Starter..."
    sudo nixos-rebuild switch --flake .
    home-manager switch --flake .
    @echo "✅ Installation complete! Reboot when ready."

# Maintenance
optimize:
    sudo nix-store --optimize

repair:
    sudo nix-store --repair --verify --check-contents

# Backup (create backup of current configuration)
backup:
    mkdir -p backups/$(date +%Y%m%d_%H%M%S)
    cp -r . backups/$(date +%Y%m%d_%H%M%S)/

# Help for new users
help:
    @echo "🌟 NixOS Starter - Quick Help"
    @echo ""
    @echo "📋 First time setup:"
    @echo "  just install-setup    # Show installation instructions"
    @echo "  just install          # Install configuration"
    @echo ""
    @echo "🔄 Daily usage:"
    @echo "  just rebuild          # Apply system changes"
    @echo "  just home-rebuild     # Apply user changes"
    @echo "  just update-rebuild   # Update everything and rebuild"
    @echo ""
    @echo "🧹 Maintenance:"
    @echo "  just clean           # Clean old generations"
    @echo "  just optimize        # Optimize nix store"
    @echo "  just check           # Check configuration"
    @echo ""
    @echo "🔧 Development:"
    @echo "  just dev             # Enter development shell"
    @echo "  just fmt             # Format Nix files"
    @echo "  just lint            # Lint Nix files"
    @echo ""
    @echo "📚 Learn more: Check README.md or visit https://nixos.org/learn.html"
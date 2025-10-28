# NixOS Dotfiles - Command Runner
# Use 'just <command>' to run these commands

# Default recipe (shows help)
default:
    @just --list

# System management
rebuild:
    sudo nixos-rebuild switch --flake ~/dotfiles#anonfunc

rebuild-test:
    sudo nixos-rebuild test --flake ~/dotfiles#anonfunc

home-rebuild:
    home-manager switch --flake ~/dotfiles#jstcz@anonfunc

# Full system update and rebuild
update-rebuild:
    nix flake update ~/dotfiles
    sudo nixos-rebuild switch --flake ~/dotfiles#anonfunc
    home-manager switch --flake ~/dotfiles#jstcz@anonfunc

# Update flake inputs
update:
    cd ~/dotfiles && nix flake update

# Clean old generations (keep last 5)
clean:
    sudo nix-collect-garbage -d --delete-older-than 7d
    nix-collect-garbage -d --delete-older-than 7d

# Development
check:
    cd ~/dotfiles && nix flake check

fmt:
    cd ~/dotfiles && nix fmt

lint:
    cd ~/dotfiles && statix check .
    cd ~/dotfiles && deadnix .

# Show system info
info:
    nix-shell -p nix-info --run "nix-info -m"

# Show flake info
flake-info:
    cd ~/dotfiles && nix flake show

# Enter development shell
dev:
    cd ~/dotfiles && nix develop

# Boot configuration
boot-list:
    sudo /run/current-system/bin/switch-to-configuration --list-generations

boot-rollback:
    sudo nixos-rebuild switch --flake ~/dotfiles#anonfunc --rollback

# Hardware info (run before installation)
hardware-scan:
    sudo nixos-generate-config --show-hardware-config

# Installation helpers
install-setup:
    @echo "🚀 NixOS Dotfiles Installation Setup"
    @echo "1. First, copy your hardware-configuration.nix from /etc/nixos/"
    @echo "2. Edit flake.nix with your hostname and user details"
    @echo "3. Run: just install"

install:
    @echo "🔧 Installing NixOS configuration..."
    sudo nixos-rebuild switch --flake ~/dotfiles#anonfunc
    home-manager switch --flake ~/dotfiles#jstcz@anonfunc
    @echo "✅ Installation complete! Reboot when ready."

# Maintenance
optimize:
    sudo nix-store --optimize

repair:
    sudo nix-store --repair --verify --check-contents

# Backup (create backup of current configuration)
backup:
    mkdir -p ~/dotfiles/backups/$(date +%Y%m%d_%H%M%S)
    cp -r ~/dotfiles/* ~/dotfiles/backups/$(date +%Y%m%d_%H%M%S)/

# Help for new users
help:
    @echo "🌟 NixOS Dotfiles - Quick Help"
    @echo ""
    @echo "📋 First time setup:"
    @echo "  just install-setup    # Show installation instructions"
    @echo "  just install          # Install configuration"
    @echo ""
    @echo "🔄 Daily usage:"
    @echo "  just rebuild          # Apply system changes (anonfunc)"
    @echo "  just home-rebuild     # Apply user changes (jstcz@anonfunc)"
    @echo "  just update-rebuild   # Update everything and rebuild"
    @echo ""
    @echo "🧹 Maintenance:"
    @echo "  just clean            # Clean old generations"
    @echo "  just optimize         # Optimize nix store"
    @echo "  just check            # Check configuration"
    @echo "  just backup           # Backup current configuration"
    @echo ""
    @echo "🔧 Development:"
    @echo "  just dev              # Enter development shell"
    @echo "  just fmt              # Format Nix files"
    @echo "  just lint             # Lint Nix files"
    @echo ""
    @echo "🔙 Recovery:"
    @echo "  just boot-list        # List boot generations"
    @echo "  just boot-rollback    # Rollback to previous generation"
    @echo ""
    @echo "📚 All configuration in: ~/dotfiles"

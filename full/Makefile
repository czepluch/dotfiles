# NixOS Dotfiles Makefile
# Common tasks for managing the dotfiles configuration

.PHONY: help install update rebuild home-rebuild check format lint clean test backup restore

# Default target
help: ## Show this help message
	@echo "NixOS Dotfiles Management"
	@echo "========================="
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Configuration:"
	@echo "  HOSTNAME = laptop"
	@echo "  USER     = $(shell whoami)"
	@echo "  FLAKE    = $(shell pwd)"

# Installation
install: ## Install the complete dotfiles configuration
	@echo "Installing NixOS dotfiles..."
	./scripts/install.sh

install-dry: ## Dry run installation (show what would be done)
	@echo "Dry run installation..."
	./scripts/install.sh --dry-run

# System management
rebuild: ## Rebuild NixOS system configuration
	@echo "Rebuilding NixOS configuration..."
	sudo nixos-rebuild switch --flake .#laptop

rebuild-test: ## Test NixOS configuration without switching
	@echo "Testing NixOS configuration..."
	sudo nixos-rebuild test --flake .#laptop

rebuild-boot: ## Build NixOS configuration for next boot
	@echo "Building NixOS configuration for next boot..."
	sudo nixos-rebuild boot --flake .#laptop

rebuild-dry: ## Dry build NixOS configuration
	@echo "Dry building NixOS configuration..."
	sudo nixos-rebuild dry-build --flake .#laptop

# Home Manager
home-rebuild: ## Rebuild Home Manager configuration
	@echo "Rebuilding Home Manager configuration..."
	home-manager switch --flake .#dev@laptop

home-rebuild-dry: ## Dry run Home Manager rebuild
	@echo "Dry building Home Manager configuration..."
	home-manager build --flake .#dev@laptop

# Flake management
update: ## Update flake inputs
	@echo "Updating flake inputs..."
	nix flake update
	@echo "Updated flake.lock"

update-input: ## Update specific flake input (usage: make update-input INPUT=nixpkgs)
	@if [ -z "$(INPUT)" ]; then \
		echo "Usage: make update-input INPUT=<input-name>"; \
		echo "Available inputs:"; \
		nix flake metadata --json | jq -r '.locks.nodes.root.inputs | keys[]'; \
	else \
		echo "Updating $(INPUT)..."; \
		nix flake lock --update-input $(INPUT); \
	fi

check: ## Check flake validity and run tests
	@echo "Checking flake configuration..."
	nix flake check --all-systems
	@echo "✓ Flake check passed"

# Code quality
format: ## Format all Nix files
	@echo "Formatting Nix files..."
	find . -name "*.nix" -type f -exec nixpkgs-fmt {} +
	@echo "✓ Formatting complete"

lint: ## Lint Nix files for issues
	@echo "Linting Nix files..."
	@if command -v statix >/dev/null 2>&1; then \
		statix check .; \
	else \
		echo "statix not found, skipping lint"; \
	fi
	@if command -v deadnix >/dev/null 2>&1; then \
		deadnix .; \
	else \
		echo "deadnix not found, skipping dead code check"; \
	fi

# Cleanup
clean: ## Clean up old generations and garbage collect
	@echo "Cleaning up old generations..."
	sudo nix-collect-garbage -d
	nix-collect-garbage -d
	@echo "Optimizing nix store..."
	sudo nix-store --optimise
	@echo "✓ Cleanup complete"

clean-old: ## Remove generations older than 7 days
	@echo "Removing old generations (>7 days)..."
	sudo nix-collect-garbage --delete-older-than 7d
	nix-collect-garbage --delete-older-than 7d

# Development
dev: ## Enter development shell
	@echo "Entering development shell..."
	nix develop

shell: ## Start nix-shell with common tools
	nix-shell -p nixd nil nixpkgs-fmt statix deadnix home-manager git

# Testing
test-vm: ## Build and test configuration in VM
	@echo "Building VM for testing..."
	nixos-rebuild build-vm --flake .#laptop
	@echo "VM built. Run ./result/bin/run-*-vm to test"

test-iso: ## Build installation ISO with this configuration
	@echo "Building installation ISO..."
	nix build .#nixosConfigurations.iso.config.system.build.isoImage

# Documentation
docs: ## Generate documentation
	@echo "Generating documentation..."
	@if command -v mdbook >/dev/null 2>&1; then \
		cd docs && mdbook build; \
	else \
		echo "mdbook not found, install with: nix-env -iA nixos.mdbook"; \
	fi

# Git operations
diff: ## Show changes since last commit
	git diff

status: ## Show git status
	git status

commit: ## Commit changes with conventional commit format
	@echo "Staging all changes..."
	git add .
	@echo "Committing changes..."
	git commit

push: ## Push changes to remote
	git push

pull: ## Pull latest changes
	git pull

# Backup and restore
backup: ## Backup current system configuration
	@echo "Creating backup..."
	@mkdir -p backups
	@cp -r /etc/nixos backups/etc-nixos-$(shell date +%Y%m%d-%H%M%S)
	@if [ -d ~/.config/home-manager ]; then \
		cp -r ~/.config/home-manager backups/home-manager-$(shell date +%Y%m%d-%H%M%S); \
	fi
	@echo "✓ Backup created in backups/"

restore-hardware: ## Restore hardware configuration from /etc/nixos
	@echo "Restoring hardware configuration..."
	@cp /etc/nixos/hardware-configuration.nix nix/hosts/laptop/
	@echo "✓ Hardware configuration restored"

# Information
show: ## Show flake outputs
	nix flake show

info: ## Show system information
	@echo "System Information:"
	@echo "=================="
	@echo "Hostname:     $(shell hostname)"
	@echo "User:         $(shell whoami)"
	@echo "NixOS:        $(shell nixos-version)"
	@echo "Kernel:       $(shell uname -r)"
	@echo "Uptime:       $(shell uptime -p)"
	@echo "Flake path:   $(shell pwd)"
	@echo ""
	@echo "Nix Store:"
	@echo "=========="
	@du -sh /nix/store 2>/dev/null || echo "Cannot read /nix/store size"
	@echo ""
	@echo "Generations:"
	@echo "============"
	@sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5

history: ## Show recent system generations
	@echo "Recent NixOS generations:"
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
	@echo ""
	@echo "Recent Home Manager generations:"
	@if [ -d ~/.local/state/nix/profiles ]; then \
		nix-env --list-generations --profile ~/.local/state/nix/profiles/home-manager; \
	else \
		echo "No Home Manager generations found"; \
	fi

# Hardware specific
hardware-info: ## Show detailed hardware information
	@echo "Hardware Information:"
	@echo "==================="
	@echo "CPU:"
	@lscpu | head -20
	@echo ""
	@echo "Memory:"
	@free -h
	@echo ""
	@echo "Graphics:"
	@lspci | grep -i vga
	@echo ""
	@echo "Storage:"
	@lsblk
	@echo ""
	@echo "Network:"
	@ip link show

# Shortcuts
r: rebuild ## Shortcut for rebuild
hr: home-rebuild ## Shortcut for home-rebuild
u: update ## Shortcut for update
c: check ## Shortcut for check
f: format ## Shortcut for format

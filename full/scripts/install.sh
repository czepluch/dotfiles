#!/usr/bin/env bash

# NixOS Dotfiles Installation Script
# This script helps set up the dotfiles repository and applies the configuration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DOTFILES_DIR="${HOME}/dotfiles"
HOSTNAME=""
USERNAME="${USER}"
DRY_RUN=false
SKIP_HARDWARE=false

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Install NixOS dotfiles configuration with flakes and Home Manager.

OPTIONS:
    -h, --help              Show this help message
    -d, --dotfiles DIR      Dotfiles directory (default: ~/dotfiles)
    -u, --username USER     Username for Home Manager (default: current user)
    -H, --hostname HOST     Hostname for NixOS configuration (default: auto-detect)
    -n, --dry-run           Show what would be done without making changes
    -s, --skip-hardware     Skip hardware configuration copy
    --first-install         First time installation from NixOS ISO

EXAMPLES:
    $0                                  # Basic installation
    $0 --hostname laptop               # Specify hostname
    $0 --dry-run                        # Preview changes
    $0 --first-install                  # Install from NixOS ISO

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -d|--dotfiles)
                DOTFILES_DIR="$2"
                shift 2
                ;;
            -u|--username)
                USERNAME="$2"
                shift 2
                ;;
            -H|--hostname)
                HOSTNAME="$2"
                shift 2
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -s|--skip-hardware)
                SKIP_HARDWARE=true
                shift
                ;;
            --first-install)
                FIRST_INSTALL=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Check if we're running on NixOS
check_nixos() {
    if [[ ! -f /etc/os-release ]] || ! grep -q "ID=nixos" /etc/os-release; then
        print_error "This script is designed for NixOS only"
        exit 1
    fi
}

# Check for required commands
check_dependencies() {
    local missing_deps=()

    for cmd in git nix; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install: nix-env -iA nixos.git"
        exit 1
    fi
}

# Auto-detect hostname if not provided
detect_hostname() {
    if [[ -z "$HOSTNAME" ]]; then
        HOSTNAME=$(hostname)
        print_info "Auto-detected hostname: $HOSTNAME"
    fi
}

# Check if flakes are enabled
check_flakes() {
    if ! nix show-config | grep -q "experimental-features.*flakes" 2>/dev/null; then
        print_warning "Flakes are not enabled. They will be enabled by the configuration."

        # Temporarily enable flakes for this session
        export NIX_CONFIG="experimental-features = nix-command flakes"
        print_info "Temporarily enabled flakes for installation"
    fi
}

# Clone or update dotfiles repository
setup_dotfiles() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        print_info "Cloning dotfiles repository..."
        if [[ "$DRY_RUN" == "false" ]]; then
            git clone https://github.com/yourusername/dotfiles.git "$DOTFILES_DIR"
        else
            print_info "[DRY RUN] Would clone dotfiles to $DOTFILES_DIR"
        fi
    else
        print_info "Dotfiles directory exists, updating..."
        if [[ "$DRY_RUN" == "false" ]]; then
            cd "$DOTFILES_DIR"
            git pull
        else
            print_info "[DRY RUN] Would update dotfiles in $DOTFILES_DIR"
        fi
    fi
}

# Copy hardware configuration
setup_hardware_config() {
    if [[ "$SKIP_HARDWARE" == "true" ]]; then
        print_warning "Skipping hardware configuration copy"
        return
    fi

    local hardware_dir="$DOTFILES_DIR/nix/hosts/$HOSTNAME"
    local hardware_file="$hardware_dir/hardware-configuration.nix"

    print_info "Setting up hardware configuration..."

    if [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$hardware_dir"

        if [[ -f "/etc/nixos/hardware-configuration.nix" ]]; then
            cp /etc/nixos/hardware-configuration.nix "$hardware_file"
            print_success "Copied hardware configuration"
        else
            print_warning "No hardware configuration found at /etc/nixos/hardware-configuration.nix"
            print_info "You may need to generate one with: nixos-generate-config"
        fi
    else
        print_info "[DRY RUN] Would copy hardware config to $hardware_file"
    fi
}

# Check if host configuration exists
check_host_config() {
    local host_config="$DOTFILES_DIR/nix/hosts/$HOSTNAME/system.nix"

    if [[ ! -f "$host_config" ]]; then
        print_error "Host configuration not found: $host_config"
        print_info "Available hosts:"
        find "$DOTFILES_DIR/nix/hosts" -maxdepth 1 -type d -exec basename {} \; | grep -v hosts
        exit 1
    fi
}

# Install Home Manager if not present
setup_home_manager() {
    if ! command -v home-manager >/dev/null 2>&1; then
        print_info "Installing Home Manager..."
        if [[ "$DRY_RUN" == "false" ]]; then
            nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
            nix-channel --update
            nix-shell '<home-manager>' -A install
        else
            print_info "[DRY RUN] Would install Home Manager"
        fi
    else
        print_info "Home Manager already installed"
    fi
}

# Apply NixOS configuration
apply_nixos_config() {
    print_info "Applying NixOS configuration..."

    local flake_uri="$DOTFILES_DIR#$HOSTNAME"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would run: sudo nixos-rebuild switch --flake $flake_uri"
        return
    fi

    # First, do a dry-build to check for errors
    print_info "Checking configuration validity..."
    if ! sudo nixos-rebuild dry-build --flake "$flake_uri"; then
        print_error "Configuration has errors. Please fix them before proceeding."
        exit 1
    fi

    # Apply the configuration
    print_info "Rebuilding NixOS system..."
    sudo nixos-rebuild switch --flake "$flake_uri"
    print_success "NixOS configuration applied successfully"
}

# Apply Home Manager configuration
apply_home_config() {
    print_info "Applying Home Manager configuration..."

    local flake_uri="$DOTFILES_DIR#$USERNAME@$HOSTNAME"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would run: home-manager switch --flake $flake_uri"
        return
    fi

    # Check if home configuration exists
    if ! nix flake show "$DOTFILES_DIR" 2>/dev/null | grep -q "homeConfigurations.*$USERNAME@$HOSTNAME"; then
        print_warning "Home configuration for $USERNAME@$HOSTNAME not found"
        print_info "Available home configurations:"
        nix flake show "$DOTFILES_DIR" 2>/dev/null | grep "homeConfigurations" || true
        return
    fi

    # Apply home manager configuration
    home-manager switch --flake "$flake_uri"
    print_success "Home Manager configuration applied successfully"
}

# Update flake inputs
update_flake() {
    if [[ "$DRY_RUN" == "false" ]]; then
        print_info "Updating flake inputs..."
        cd "$DOTFILES_DIR"
        nix flake update
        print_success "Flake inputs updated"
    else
        print_info "[DRY RUN] Would update flake inputs"
    fi
}

# Main installation function
main() {
    print_info "Starting NixOS dotfiles installation..."

    # Pre-flight checks
    check_nixos
    check_dependencies
    detect_hostname
    check_flakes

    # Setup
    setup_dotfiles
    setup_hardware_config

    cd "$DOTFILES_DIR"

    # Validation
    check_host_config

    # Installation
    if command -v home-manager >/dev/null 2>&1; then
        print_info "Home Manager found, using flake-based installation"
    else
        print_info "Installing Home Manager first..."
        setup_home_manager
    fi

    # Update flake inputs
    update_flake

    # Apply configurations
    apply_nixos_config
    apply_home_config

    # Success message
    print_success "Installation completed successfully!"
    print_info ""
    print_info "Next steps:"
    print_info "1. Reboot your system to ensure all changes take effect"
    print_info "2. Customize your configuration in $DOTFILES_DIR"
    print_info "3. Use 'rebuild' alias to apply future changes"
    print_info ""
    print_info "Useful commands:"
    print_info "  rebuild                    # Rebuild NixOS configuration"
    print_info "  home-rebuild              # Rebuild Home Manager configuration"
    print_info "  nix-gc                    # Clean up old generations"
    print_info "  nix flake update          # Update flake inputs"
}

# Handle script interruption
cleanup() {
    print_warning "Installation interrupted by user"
    exit 130
}

trap cleanup SIGINT SIGTERM

# Parse arguments and run main function
parse_args "$@"
main

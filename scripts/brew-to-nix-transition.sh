#!/usr/bin/env bash

# Homebrew to Nix package transition script
# This safely transitions CLI tools from Homebrew to Nix/Home Manager

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Packages to transition (excluding docker and coreutils)
PACKAGES_TO_REMOVE=(
    "eza"
    "fd"
    "bat"
    "ripgrep"
    "tree"
    "wget"
    "httpie"
    "jq"
    "lazygit"
    "gh"
)

# Packages to keep in Homebrew (for safety)
PACKAGES_TO_KEEP=(
    "docker"       # Keep until Docker Desktop integration is verified
    "coreutils"    # Keep until all scripts are tested with Nix version
)

echo "======================================"
echo "Homebrew to Nix Package Transition"
echo "======================================"
echo ""

# Step 1: Check if Home Manager is applied
echo -e "${YELLOW}Step 1: Checking Home Manager status...${NC}"
if ! command -v home-manager &> /dev/null; then
    echo -e "${RED}Error: Home Manager not found!${NC}"
    echo "Please run: home-manager switch --flake ~/dev/dotfiles#jacob@macos -b backup"
    exit 1
fi
echo -e "${GREEN}✓ Home Manager is installed${NC}"
echo ""

# Step 2: Verify Nix packages are available
echo -e "${YELLOW}Step 2: Verifying Nix packages...${NC}"
MISSING_PACKAGES=()
for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
    # Special cases for package names that differ
    NIX_CMD=$pkg

    # Check if the Nix version exists
    if ! command -v $NIX_CMD &> /dev/null; then
        MISSING_PACKAGES+=($pkg)
        echo -e "${RED}✗ $pkg not found in Nix${NC}"
    else
        NIX_PATH=$(which $NIX_CMD)
        if [[ $NIX_PATH == *".nix-profile"* ]]; then
            echo -e "${GREEN}✓ $pkg found at $NIX_PATH${NC}"
        else
            echo -e "${YELLOW}⚠ $pkg found but not in Nix profile: $NIX_PATH${NC}"
        fi
    fi
done
echo ""

# Step 3: Check for packages that would be removed
echo -e "${YELLOW}Step 3: Checking Homebrew packages...${NC}"
BREW_PACKAGES_FOUND=()
for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
    if brew list --formula | grep -q "^${pkg}$"; then
        BREW_PACKAGES_FOUND+=($pkg)
        echo -e "  • $pkg (will be removed from Homebrew)"
    fi
done

if [ ${#BREW_PACKAGES_FOUND[@]} -eq 0 ]; then
    echo -e "${GREEN}No duplicate packages found in Homebrew!${NC}"
    exit 0
fi
echo ""

# Step 4: Show packages that will be kept
echo -e "${YELLOW}Step 4: Packages staying in Homebrew:${NC}"
for pkg in "${PACKAGES_TO_KEEP[@]}"; do
    if brew list --formula | grep -q "^${pkg}$"; then
        echo -e "  • ${GREEN}$pkg${NC} (keeping in Homebrew for now)"
    fi
done
echo ""

# Step 5: Confirm before proceeding
if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo -e "${RED}Warning: Some packages are not available in Nix yet:${NC}"
    printf '%s\n' "${MISSING_PACKAGES[@]}"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

echo -e "${YELLOW}Ready to remove the following from Homebrew:${NC}"
printf '%s\n' "${BREW_PACKAGES_FOUND[@]}"
echo ""
read -p "Proceed with removal? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Step 6: Remove packages from Homebrew
echo ""
echo -e "${YELLOW}Step 6: Removing packages from Homebrew...${NC}"
for pkg in "${BREW_PACKAGES_FOUND[@]}"; do
    echo -e "Removing $pkg..."
    if brew uninstall --formula $pkg 2>/dev/null; then
        echo -e "${GREEN}✓ Removed $pkg${NC}"
    else
        echo -e "${RED}✗ Failed to remove $pkg${NC}"
    fi
done

# Step 7: Verify final state
echo ""
echo -e "${YELLOW}Step 7: Final verification...${NC}"
echo "Testing commands from Nix:"
for cmd in eza fd bat rg tree wget http jq lazygit gh; do
    if command -v $cmd &> /dev/null; then
        CMD_PATH=$(which $cmd)
        if [[ $CMD_PATH == *".nix-profile"* ]]; then
            echo -e "${GREEN}✓ $cmd → $CMD_PATH${NC}"
        else
            echo -e "${YELLOW}⚠ $cmd → $CMD_PATH (not from Nix)${NC}"
        fi
    else
        echo -e "${RED}✗ $cmd not found${NC}"
    fi
done

echo ""
echo -e "${GREEN}Transition complete!${NC}"
echo ""
echo "Notes:"
echo "  • Docker and coreutils remain in Homebrew (safe approach)"
echo "  • If any tools are missing, you can reinstall with: brew install <package>"
echo "  • To update Nix packages: nix flake update ~/dev/dotfiles"
echo ""
echo "Recommended next steps:"
echo "  1. Test your commonly used commands"
echo "  2. Restart your terminal to ensure PATH is correct"
echo "  3. Run 'brew cleanup' to remove old versions"

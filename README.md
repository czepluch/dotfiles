# dotfiles

My cross-platform dotfiles for Arch Linux and macOS, managed with GNU Stow.

## Setup

### Prerequisites

**macOS:**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install GNU Stow and essential tools
brew install stow eza bat fd ripgrep fzf starship zoxide yazi lazygit mise neovim \
  zsh-autosuggestions zsh-syntax-highlighting
```

**Arch Linux:**
```bash
# Install with your preferred AUR helper (e.g., paru)
paru -S stow eza bat fd ripgrep fzf starship zoxide yazi lazygit mise neovim \
  zsh-autosuggestions zsh-syntax-highlighting keychain
```

### Installation

```bash
git clone git@github.com:czepluch/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
stow -t ~ zsh nvim starship ghostty yazi mise
```

## Structure

Each directory is a "stow package" that contains configs symlinked to `~/`:

### Cross-Platform (macOS & Linux)
- **zsh** - Shell configuration with modern CLI tools (OS-aware)
- **starship** - Custom prompt theme (Base2Tone Field Dark)
- **nvim** - Neovim/LazyVim configuration with Avante & Supermaven
- **yazi** - Terminal file manager configuration
- **mise** - Version manager for development tools
- **ghostty** - Terminal emulator theme (macOS)
- **kitty** - Terminal emulator theme (Linux)

### Linux-Only (Wayland/Hyprland)
- **hypr** - Hyprland compositor configuration
- **waybar** - Status bar configuration
- **mako** - Notification daemon configuration
- **fuzzel** - Application launcher
- **btop** - System monitor
- **podman** - Container runtime configuration

### Not Managed (Use System Configs)
- **git** - Use your own git config
- **ssh** - Use your own SSH config

## Usage

```bash
# Install all cross-platform packages
cd ~/dev/dotfiles
stow -t ~ zsh nvim starship yazi mise

# macOS: Install ghostty
stow -t ~ ghostty

# Linux: Install kitty and Wayland packages
stow -t ~ kitty hypr waybar mako fuzzel btop podman

# Uninstall a package
stow -D -t ~ zsh

# Reinstall a package (useful after updates)
stow -R -t ~ nvim
```

## Features

### Shell (Zsh)
- OS-aware configuration (macOS/Linux)
- Modern CLI tools: `eza`, `bat`, `fd`, `rg`, `fzf`
- Smart directory navigation with `zoxide`
- Rich git aliases
- History search with arrow keys
- Auto-suggestions and syntax highlighting

### Editor (Neovim/LazyVim)
- Avante integration with OpenCode ACP provider
- Supermaven AI completion
- Language support: Rust, Gleam, Solidity
- Custom keymaps and settings

### Terminal
- **macOS**: Ghostty with Base2Tone Field Dark theme
- **Linux**: Kitty with Base2Tone Field Dark theme
- Starship prompt with custom styling
- 95% background opacity

### Version Management (Mise)
- Node.js (latest)
- Erlang, Gleam, Solidity, Foundry (latest)
- Idiomatic version file support

## System Configurations

### macOS
- **OS**: macOS
- **Shell**: Zsh
- **Terminal**: Ghostty
- **Editor**: Neovim (LazyVim)
- **Theme**: Base2Tone Field Dark

### Arch Linux
- **OS**: Arch Linux
- **WM**: Hyprland (Wayland)
- **Shell**: Zsh
- **Terminal**: Kitty
- **Editor**: Neovim (LazyVim)
- **Theme**: Base2Tone Field Dark

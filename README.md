# dotfiles

My Arch Linux dotfiles managed with GNU Stow.

## Setup

```bash
git clone git@github.com:czepluch/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow */
```

## Structure

Each directory is a "stow package" that contains configs symlinked to `~/`:

- **zsh** - Shell configuration with modern CLI tools
- **starship** - Custom prompt theme (Base2Tone Field Dark)
- **git** - Git configuration and aliases
- **ssh** - SSH client config (keys not included)
- **hypr** - Hyprland compositor configuration
- **waybar** - Status bar configuration
- **kitty** - Terminal emulator theme
- **nvim** - Neovim/LazyVim configuration
- **yazi** - File manager configuration

## Usage

```bash
# Install all packages
stow */

# Install specific package
stow zsh

# Uninstall package
stow -D zsh

# Reinstall package
stow -R zsh
```

## System

- **OS**: Arch Linux
- **WM**: Hyprland (Wayland)
- **Shell**: Zsh
- **Terminal**: Kitty
- **Editor**: Neovim (LazyVim)
- **Theme**: Base2Tone Field Dark

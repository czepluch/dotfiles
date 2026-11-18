# dotfiles

My cross-platform dotfiles for Arch Linux and macOS, managed with GNU Stow.

## Setup

### Prerequisites

**macOS:**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install GNU Stow and essential tools
brew install stow eza bat fd ripgrep fzf starship zoxide yazi lazygit mise direnv neovim \
  zsh-autosuggestions zsh-syntax-highlighting
```

**Arch Linux:**
```bash
# Install with your preferred AUR helper (e.g., paru)
paru -S stow eza bat fd ripgrep fzf starship zoxide yazi lazygit mise direnv neovim \
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
- **nvim** - Neovim/LazyVim configuration
- **yazi** - Terminal file manager configuration
- **eza** - ls replacement theme (symlink into the theme system output)
- **herdr** - Terminal workspace manager for AI coding agents (symlink into the theme system output)
- **herdr-app** - Herdr desktop app config
  - `keys.json` and `settings.json`; the app writes zoom and Settings changes back into `settings.json`
  - the `my-main` layout, a copy of the shipped `main` that uses 4 copied mods:
    - `mods/my-status`: the status bar, plus the ETH/USD price from the Chainlink feed (read through the DappNode execution client) with a green or red arrow for its last move, and the Claude plan usage limits that `~/.claude/statusline.sh` saves to `~/.cache/claude-statusline/`
    - `mods/my-spaces`: each space as a card with its branch, ahead/behind, uncommitted files, pull request (through `gh`), tabs and agents
    - `mods/my-agents`: the agents list, plus each Claude Code agent's model and effort from the same status line cache, read over herdr's connection for agents on other machines (each machine needs a status line that saves to that cache)
    - `mods/my-changes`: the Changes panel, with added and removed lines at 25% of green and red and modified files in yellow
  - `themes/palette.json`: symlink into the theme system output (see `themes/SPEC.md`)
  - The window is 92% opaque like Ghostty: `my-main` turns on `window_blur` (without it the window is opaque), the theme sets the alphas (see `themes/SPEC.md`), and a Hyprland rule in `hypr/.config/hypr/lua/rules.lua` turns the blur off again
  - The app reloads an edited mod or layout only after `touch -h` on its symlink in `~/.config/herdr-app`
  - On a new machine, start herdr-app once before `stow herdr-app` (or use `stow --no-folding herdr-app`), otherwise stow links the whole `~/.config/herdr-app` folder into the repo and the app writes its state there
- **mise** - Version manager for development tools
- **direnv** - Loads per-directory environments, such as Nix flake dev shells
- **ghostty** - Terminal emulator theme (macOS)
- **kitty** - Terminal emulator theme (Linux)

### Linux-Only (Wayland/Hyprland)
- **hypr** - Hyprland compositor configuration
- **waybar** - Former status bar, no longer started (the Quickshell bar replaced it); `dnd.sh` in it is still used by SUPER+N
- **mako** - Notification daemon configuration
- **quickshell** - Bar and lock screen in QML, run as `qs -c main` by `quickshell.service`; `bar-test.qml` shows a second bar along the bottom for trying changes
- **fuzzel** - Application launcher
- **btop** - System monitor
- **podman** - Container runtime configuration
- **screensaver** - Terminal screensaver: logo text art animated by `ttfx`, run manually with `screensaver`
- **xdg** - Default applications for `xdg-open` under Hyprland: text files in Neovim (new Ghostty window), images in imv

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
stow -t ~ kitty hypr waybar mako fuzzel btop podman xdg

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

# Personal Config Reference

Quick reference for setting up a new system.

## Git Config

```
Name: Jacob Czepluch
Email: j.czepluch@proton.me
Editor: zed --wait
Default branch: main
```

## Keyboard

```
Layout: us,dk
Toggle: Ctrl+Space
Caps Lock: Escape
```

## Monitor

```
Display: 2880x1800@60Hz
Scaling: 1.5x
Monitor ID: eDP-1
```

## Kernel Parameters (AMD Ryzen Laptop)

```
atkbd.reset=1 i8042.reset=1
```

Add to bootloader config to fix keyboard not waking from suspend.

## Shell Aliases

```bash
alias ll='eza -la --git'
alias ls='eza --icons'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias ..='cd ..'
alias ...='cd ../..'
alias up='cd ..'
```

## Apps/Packages

### Core CLI Tools
```
zsh zsh-autosuggestions zsh-syntax-highlighting
eza bat ripgrep fd fzf zoxide
starship tmux
git git-delta lazygit gh
btop fastfetch
jq yq
```

### Desktop
```
hyprland waybar wofi mako
hyprlock hypridle hyprpicker
kitty alacritty
wl-clipboard cliphist grim slurp
```

### GUI Apps
```
firefox
zed
bitwarden
vlc mpv
```

### Development
```
neovim
rustup
gcc
lua-language-server stylua
```

### Fonts
```
ttf-jetbrains-mono-nerd
ttf-hack-nerd
noto-fonts noto-fonts-emoji
ttf-font-awesome
```

## System Services

```bash
# Enable these
systemctl enable bluetooth.service
systemctl enable NetworkManager.service
```

## Zsh Setup

```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Plugins location: ~/.oh-my-zsh/custom/plugins/
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

## Config Locations

```
~/.config/hypr/          # Hyprland
~/.config/waybar/        # Status bar
~/.config/wofi/          # Launcher
~/.config/zed/           # Zed editor
~/.zshrc                 # Shell
~/.gitconfig             # Git
```

---

## Old Configs

- `nixos-archive/` - Original NixOS setup (backup)
- `.config/` - Extracted configs from NixOS (reference)
- `omarchy-overlay/` - Minimal overlay files

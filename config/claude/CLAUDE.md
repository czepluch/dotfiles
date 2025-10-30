# System-Wide Claude Code Instructions

This file contains system-wide instructions for Claude Code on this NixOS system.

---

## 🛠️ TOOL PREFERENCES

### Use Modern Alternatives

When working on this system, prefer modern tools over traditional Unix utilities:

**File Search & Content Search:**
- ✅ Use `rg` (ripgrep) instead of `grep`
- ✅ Use `fd` instead of `find`
- ✅ Use `fzf` for fuzzy finding

**File Operations:**
- ✅ Use `eza` instead of `ls` (with colors and git integration)
- ✅ Use `bat` instead of `cat` (syntax highlighting)
- ✅ Use `dust` instead of `du` (better disk usage)
- ✅ Use `duf` instead of `df` (better disk free)

**System Monitoring:**
- ✅ Use `btop` instead of `htop` or `top`
- ✅ Use `bandwhich` for network monitoring

**Examples:**
```bash
# Search for content in files
rg "pattern" path/          # Instead of: grep -r "pattern" path/

# Search for files
fd "filename"               # Instead of: find . -name "filename"

# List directory contents
eza -la                     # Instead of: ls -la
eza --tree                  # Tree view with colors

# View file contents
bat file.txt                # Instead of: cat file.txt

# Disk usage
dust                        # Instead of: du -h
duf                         # Instead of: df -h
```

---

## 🏗️ NIXOS-SPECIFIC PRACTICES

### Configuration Management

**File Locations:**
- System config: `/home/jstcz/dotfiles/system/`
- User config: `/home/jstcz/dotfiles/home/`
- Host-specific: `/home/jstcz/dotfiles/nix/hosts/anonfunc/`

**Always use declarative configuration:**
```nix
# ✅ Good - Declarative via home-manager
xdg.configFile."app/config.yml".text = ''
  setting: value
'';

# ❌ Avoid - Imperative manual edits
# Manually editing ~/.config/app/config.yml
```

**Symlink config files in dotfiles:**
```nix
# For configs you want to edit and track in git
xdg.configFile."zed/settings.json".source = 
  config.lib.file.mkOutOfStoreSymlink 
  "${config.home.homeDirectory}/dotfiles/config/zed/settings.json";
```

### Package Installation

**Always add packages to Nix config, never use external package managers:**
- ✅ Add to `home.packages` in `home/default.nix` or `home/desktop.nix`
- ✅ Use `programs.<name>.enable = true` when available
- ❌ Don't use `npm install -g`, `pip install --user`, `cargo install`, etc.
- ❌ Don't use `apt`, `yum`, or other distro package managers

### Rebuilding the System

**After making changes:**
```bash
# System-level changes (system/*.nix)
sudo nixos-rebuild switch --flake ~/dotfiles#anonfunc

# User-level changes (home/*.nix)
home-manager switch --flake ~/dotfiles#jstcz@anonfunc

# Both (if you changed both)
sudo nixos-rebuild switch --flake ~/dotfiles#anonfunc
home-manager switch --flake ~/dotfiles#jstcz@anonfunc

# Then reboot if kernel parameters changed
sudo reboot
```

---

## 📦 AVAILABLE TOOLS

These tools are already installed and configured on this system:

### Development
- `zed-editor` - Primary code editor
- `claude-code` - Claude Code CLI
- `git` - Version control

### Terminal & Shell
- `zsh` + `oh-my-zsh` - Shell with plugins
- `starship` - Modern prompt
- `tmux` - Terminal multiplexer
- `alacritty` / `kitty` / `warp-terminal` - GPU-accelerated terminals

### File & Text Processing
- `rg` (ripgrep), `fd`, `bat`, `eza`, `dust`, `duf`
- `jq` - JSON processor
- `yq-go` - YAML processor
- `fzf` - Fuzzy finder

### System Monitoring
- `btop` - System monitor
- `bandwhich` - Network monitor
- `hyperfine` - Benchmarking

### Network
- `curl`, `wget`, `httpie`, `rsync`
- `gping` - Ping with graphs

---

## 🎯 CODING STANDARDS

### Git Practices
- Write clear, descriptive commit messages
- One logical change per commit
- Test changes before committing

### NixOS Config Style
- Use comments to explain non-obvious settings
- Group related settings together
- Keep kernel parameters documented (like atkbd.reset=1)
- Prefer standard/recommended approaches over hacks

### Documentation
- Update `CLAUDE.md` (project-specific) when solving complex issues
- Include "why" not just "what" in comments
- Document hardware-specific workarounds

---

## ⚠️ IMPORTANT NOTES

### Hardware-Specific Fixes
This system has an AMD Ryzen AI 9 365 CPU with specific kernel parameters for keyboard wake-from-suspend:
```nix
boot.kernelParams = [
  "atkbd.reset=1"  # Required for keyboard after suspend
  "i8042.reset=1"  # Required for PS/2 controller reset
];
```
**Do not remove these** - they fix a hardware bug.

### Existing Quirks
- Caps Lock mapped to Escape (Hyprland-only, not TTY)
- 1.5x display scaling for 2880x1800 resolution
- Battery-only auto-suspend after 10 minutes idle

---

**Last Updated:** 2025-10-30  
**System:** NixOS with Hyprland on Framework laptop (AMD Ryzen AI 9 365)

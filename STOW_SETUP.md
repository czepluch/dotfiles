# GNU Stow Setup Guide

## Overview

This repository uses **GNU Stow** to manage dotfiles via symlinks. All configs are organized into packages that mirror your home directory structure.

**Important:** After stowing, you'll edit files in `~/dotfiles/` and changes will automatically reflect in your active configs (via symlinks).

---

## Current Status

✅ **All configs committed to git** (commit `46f3dee`)  
⚠️ **Not yet pushed to GitHub** (requires SSH key passphrase)  
❌ **Stow not yet applied** (configs still in original locations)

---

## Package Structure

```
~/dotfiles/
├── fuzzel/.config/fuzzel/fuzzel.ini
├── git/.gitconfig
├── hypr/.config/hypr/
│   ├── hyprland.conf
│   ├── hypridle.conf
│   ├── hyprlock.conf
│   └── hyprpaper.conf
├── kitty/.config/kitty/
│   ├── kitty.conf
│   └── current-theme.conf
├── mako/.config/mako/config
├── mise/.config/mise/config.toml
├── nvim/.config/nvim/
│   └── (entire LazyVim setup)
├── ssh/.ssh/config
├── starship/.config/starship.toml
├── waybar/.config/waybar/
│   ├── config.jsonc
│   └── style.css
├── yazi/.config/yazi/
│   ├── yazi.toml
│   ├── keymap.toml
│   └── theme.toml
└── zsh/.zshrc
```

---

## Prerequisites

1. **GNU Stow installed:**
   ```bash
   paru -S stow
   ```

2. **Git repo pushed to GitHub** (do this first!):
   ```bash
   # Unlock SSH keys
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ssh-add ~/.ssh/id_rsa
   
   # Push dotfiles
   cd ~/dotfiles
   git push origin main
   ```

---

## Step-by-Step Setup

### 1. Backup Existing Configs (Recommended)

```bash
mkdir -p ~/backup-configs
cp -r ~/.config ~/backup-configs/config-$(date +%Y%m%d-%H%M%S)
cp ~/.zshrc ~/backup-configs/
cp ~/.gitconfig ~/backup-configs/
```

### 2. Remove Original Configs

**Important:** Stow will fail if files/directories already exist at the target location.

```bash
# Remove config directories
rm -rf ~/.config/fuzzel
rm -rf ~/.config/mako
rm -rf ~/.config/mise
rm -rf ~/.config/hypr
rm -rf ~/.config/waybar
rm -rf ~/.config/kitty
rm -rf ~/.config/nvim
rm -rf ~/.config/yazi

# Remove config files
rm ~/.zshrc
rm ~/.gitconfig
rm ~/.config/starship.toml

# SSH requires special handling (see below)
```

### 3. Apply Stow

```bash
cd ~/dotfiles

# Stow all packages (except SSH for now)
stow zsh starship git hypr waybar kitty nvim yazi fuzzel mako mise

# Verify symlinks were created
ls -la ~/ | grep "\.zshrc"
ls -la ~/.config/ | grep -E "(hypr|waybar|kitty|nvim|yazi|fuzzel|mako|mise)"
```

### 4. SSH Special Handling

**SSH keys should NOT be symlinked** (security best practice). Only symlink the config file:

```bash
# Backup SSH keys (if not already done)
cp -r ~/.ssh ~/backup-configs/ssh-$(date +%Y%m%d-%H%M%S)

# Remove only the config file
rm ~/.ssh/config

# Stow just the SSH package
stow ssh

# Verify: config is a symlink, keys are real files
ls -la ~/.ssh/
```

### 5. Reload Configs

```bash
# Reload shell
source ~/.zshrc

# Reload Hyprland (from within Hyprland)
hyprctl reload

# Reload Waybar
killall waybar && waybar &

# Neovim will reload automatically on next launch
```

---

## Verifying Success

**Check for symlinks:**
```bash
# Should show symlinks pointing to ~/dotfiles/
ls -la ~/.zshrc
ls -la ~/.gitconfig
ls -la ~/.config/hypr/hyprland.conf
ls -la ~/.config/nvim/init.lua
```

**Example output:**
```
lrwxrwxrwx 1 jstcz jstcz 25 Nov 22 20:45 /home/jstcz/.zshrc -> dotfiles/zsh/.zshrc
```

---

## Future Workflow

### Making Changes

**✅ DO THIS:**
```bash
# Edit files in ~/dotfiles/ (they're symlinked to active configs)
nvim ~/dotfiles/hypr/.config/hypr/hyprland.conf
nvim ~/dotfiles/zsh/.zshrc
nvim ~/dotfiles/kitty/.config/kitty/kitty.conf
```

**❌ DON'T DO THIS:**
```bash
# Editing active configs will work, but it's easy to forget they're in dotfiles
nvim ~/.config/hypr/hyprland.conf  # Works, but use ~/dotfiles/ instead
```

### Committing Changes

```bash
cd ~/dotfiles
git status
git diff
git add -A
git commit -m "Update hyprland keybindings"
git push origin main
```

### Adding New Configs

```bash
cd ~/dotfiles

# Create new package structure
mkdir -p package-name/.config/package-name

# Copy config
cp -r ~/.config/package-name/* package-name/.config/package-name/

# Remove original
rm -rf ~/.config/package-name

# Stow it
stow package-name

# Commit
git add package-name/
git commit -m "Add package-name to dotfiles"
git push
```

---

## Unstowing (Reverting)

If you need to remove symlinks:

```bash
cd ~/dotfiles
stow -D package-name  # Unstow specific package
stow -D */            # Unstow everything
```

---

## Troubleshooting

### "Existing target is not a symlink"

**Problem:** Stow can't create symlink because a file/directory already exists.

**Solution:** Remove the conflicting file/directory first:
```bash
rm ~/.config/some-config
# or
rm -rf ~/.config/some-directory
```

### "Conflicts would occur"

**Problem:** Stow detected a conflict with existing files.

**Solution:** Use verbose mode to see what's conflicting:
```bash
stow -v package-name
```

### Accidentally Deleted Configs

**Solution:** Restore from backup:
```bash
cp -r ~/backup-configs/config-20251122-XXXXXX ~/.config
```

---

## Package-Specific Notes

### mako (Notification Daemon)

Currently using **Catppuccin Mocha** theme (blue/lavender). Other configs use **Base2Tone Field Dark** (teal/green).

To convert mako to Base2Tone Field Dark, edit `mako/.config/mako/config`:
```ini
background-color=#18201edd
text-color=#8ea4a0ff
border-color=#25d0b4ff
```

### SSH Keys

**Never commit private SSH keys to git!** The `.gitignore` excludes them, but verify:
```bash
cd ~/dotfiles
cat .gitignore  # Should contain: ssh/.ssh/id_*
```

### nvim (Neovim)

Includes LazyVim setup with:
- Avante.nvim (OpenCode integration)
- Supermaven (AI completion)
- Treesitter (Gleam, Solidity)
- Custom LSP configs
- Per-filetype indent settings

---

## Next Steps After Stow

1. **Test all applications** to ensure configs loaded correctly
2. **Reboot** to ensure everything persists across restarts
3. **Check CLAUDE.md** in this repo for remaining setup tasks

---

*Last updated: 2025-11-22*

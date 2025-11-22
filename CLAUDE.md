# Arch Linux Dotfiles - Setup Documentation

---
## 🚧 CONTINUE HERE - Next Session

### ⚠️ CRITICAL ISSUES

**1. Keyboard Not Working After Suspend/Resume**
**Problem:** After lid closes → suspend → lid opens → hyprlock screen, keyboard doesn't work. Cannot type password to unlock.

**ROOT CAUSE IDENTIFIED:**
- **Hardware:** Slimbook EVO14-AI9-STP with AMD Ryzen AI 9 365 (Strix Point)
- **Issue:** i8042 keyboard controller not resetting properly after s2idle suspend
- **Why:** Brand new hardware (2024) - Linux support still maturing for Strix Point
- **Confirmed:** Official Slimbook forum confirmed this is a known EVO issue

**FIX APPLIED:** ✅
Installed Slimbook's official UDEV quirk packages:
- `slimbook-quirk-i8042-wakeup` - Handles keyboard controller wake events
- `slimbook-quirk-i8042-reset` - Resets i8042 controller after resume

**Added Slimbook repository:**
```bash
curl -L https://build.opensuse.org/projects/home:Slimbook/signing_keys/download?kind=gpg -o home_Slimbook.gpg
sudo pacman-key --add home_Slimbook.gpg
echo "[home_Slimbook_Arch]" | sudo tee -a /etc/pacman.conf
echo "SigLevel = Optional TrustAll" | sudo tee -a /etc/pacman.conf
echo "Server = https://download.opensuse.org/repositories/home:/Slimbook/Arch/x86_64/" | sudo tee -a /etc/pacman.conf
sudo pacman -Syy
```

**NEXT STEPS:**
1. ✅ Packages installed - waiting for reboot to activate UDEV rules
2. **After reboot:** Test suspend/resume cycle (close lid, wait, open lid)
3. **If keyboard works:** Problem solved! Update this section to RESOLVED
4. **If keyboard still fails:**
   - Test with external keyboard (narrow down if it's internal KB only)
   - Check logs: `journalctl -b | grep -i "i8042\|atkbd\|keyboard"`
   - Contact Slimbook forum with logs for further assistance
5. **Fallback option:** Add `mem_sleep_default=deep` kernel parameter (forces S3 sleep)

---

**2. External Keyboard Input Lag**
**Problem:** External keyboard (ZSA Voyager) sometimes has severe input lag - keystrokes take ~1 second to appear. Laptop keyboard does NOT have this issue.

**Possible causes to investigate:**
- USB polling rate issues
- Power management on USB ports (USB autosuspend)
- Wayland/input handling latency
- Keyboard firmware/driver issue
- USB controller performance

**Next steps:**
1. Test if issue occurs on specific USB ports vs all ports
2. Disable USB autosuspend: `echo 'on' > /sys/bus/usb/devices/*/power/control`
3. Check `dmesg | grep -i usb` for errors when lag occurs
4. Try different USB cable
5. Check ZSA Voyager firmware settings (polling rate, etc.)

---

### Priority 1: Apply GNU Stow Setup ⚠️
**Status:** Dotfiles ready in `~/dotfiles/`, not yet applied

**Next steps:**
1. Push dotfiles to GitHub (requires SSH passphrase)
2. Follow `~/dotfiles/STOW_SETUP.md` to apply stow
3. **Important:** After stow, edit files in `~/dotfiles/` (they're symlinked)

---

### Priority 2: Debug Solidity LSP Diagnostics
- Solidity LSP (`solidity_ls_nomicfoundation`) runs but doesn't provide inline diagnostics
- Hypothesis: May be designed for Hardhat, not Foundry projects
- Next step: Try `solidity_ls` instead

---

### Quick Wins:
- [ ] Download wallpaper to `~/pics/wallpapers/wallpaper.jpg`
- [ ] Convert mako to Base2Tone Field Dark (currently Catppuccin Mocha)

---

## Context

Fresh Arch Linux setup after 5 years on macOS. Goals: Modern tools, Wayland/Hyprland, LazyVim, minimal and clean.

---

## Current Setup ✅

### Window Manager & Desktop
- **Hyprland** - Wayland compositor with vim-style navigation (SUPER+h/j/k/l)
- **Waybar** - Status bar with Base2Tone Field Dark theme
- **Mako** - Notification daemon
- **Fuzzel** - Application launcher
- **hyprpaper** - Wallpaper manager (configured, needs wallpaper)

### Terminal & Shell
- **Kitty** - Terminal emulator with Base2Tone Field Dark theme
- **Zsh** - Shell with comprehensive configuration
  - History: 10,000 lines, share across sessions, incremental search
  - SSH agent auto-start on login
  - Comprehensive aliases for modern CLI tools
  - Git aliases (gaa, gcm, gd, glog, etc.)
  - FZF integration with bat previews
  - ya() function for yazi cd-on-exit
- **Starship** - Prompt (custom Base2Tone Field theme matching terminal)
- **Plugins**: zsh-autosuggestions, zsh-syntax-highlighting (loaded directly)

### Modern CLI Tools (Rust replacements)
- **eza** → replaces `ls` (aliased in .zshrc)
- **bat** → replaces `cat` (aliased in .zshrc, with fzf preview)
- **fd** → replaces `find` (aliased in .zshrc)
- **ripgrep (rg)** → replaces `grep` (aliased in .zshrc)
- **btop** → replaces `htop`
- **zoxide** → smart `cd` replacement (aliased to `z` and `cd`)
- **fzf** → fuzzy finder (Ctrl+R for history, integrated with bat)
- **tree** → aliased to `eza --tree`

### Development Tools
- **Neovim** with **LazyVim** - Modern vim distribution
  - Avante.nvim with OpenCode/ACP integration (uses Claude Pro/Max)
  - Supermaven for AI autocompletion
  - Treesitter parsers: Gleam, Solidity
  - LSP servers: Gleam, Solidity (solidity_ls_nomicfoundation)
  - Formatters: gleam format, forge fmt
  - Custom keybinding: `jk` to escape insert mode
- **LazyGit** - Git TUI
- **Mise** - Version manager (modern replacement for asdf/nvm/pyenv)
  - Node.js 24.11.1 LTS
  - Gleam latest
  - Foundry latest (forge, cast, anvil, chisel)
  - Solidity latest
- **Git** - Configured with aliases (st, co, br, lg, gaa, gcm, etc.)

### File Managers
- **Yazi** - Modern TUI file manager (Rust)
  - Base2Tone Field Dark theme
  - Vim-style keybindings
  - Image preview with imv
  - Video preview with mpv
  - `ya()` function in .zshrc for cd-on-exit
- **Dolphin** - KDE file manager
- **Thunar** - XFCE file manager with archive plugin

### Browsers & Apps
- **Firefox** - Web browser (Wayland, scaling set to 1.5 for dual monitor)

### Screenshot Tools (installed but not configured)
- **grim** - Screenshot utility for Wayland
- **slurp** - Region selector for Wayland
- **swappy** - Screenshot annotation/editing tool
- **wl-copy** - Clipboard utility

### Power & Session Management
- **hypridle** - Idle management daemon
- **hyprlock** - Screen locker with blur effect
- Configured timeouts: 5min lock → 7min screen off → 10min suspend
- Lid closure: Suspends system (with lock)

---

## Todo List

### 🔐 Dotfiles Management (HIGH PRIORITY)
- [x] Set up GNU Stow repository structure
- [x] Migrate all configs to ~/dotfiles/
- [x] Commit configs to git
- [ ] **Push to GitHub** (requires unlocking SSH keys)
- [ ] **Apply stow** (see STOW_SETUP.md in ~/dotfiles/)
- [ ] Test all applications after stow
- [ ] Reboot and verify persistence

### 🔐 SSH & Git Configuration
- [x] Migrate SSH keys from macOS (id_ed25519 + id_rsa)
- [x] Create ~/.ssh/config with GitHub/GitLab shortcuts
- [x] Set up SSH agent auto-start in .zshrc
- [x] Configure git globally (user: jstcz, email: j.czepluch@proton.me)
- [x] Set up git aliases (st, co, br, lg, gaa, gcm, etc.)
- [x] Test SSH authentication (GitHub working)

### 📝 Neovim / LazyVim
- [ ] **DEBUG: Solidity LSP diagnostics not showing** (try `solidity_ls` instead)
- [x] Install avante.nvim for Claude integration with diff review
- [x] **Configure Avante to use OpenCode via ACP (uses Claude Pro/Max subscription!)**
- [ ] **BLOCKED: Inline diff review not working with ACP providers (OpenCode)**
  - **Issue 1:** Changes apply directly without conflict markers - https://github.com/yetone/avante.nvim/issues/2689
  - **Issue 2:** Automatic application without review - https://github.com/yetone/avante.nvim/issues/2750
  - **Root Cause:** ACP providers (like OpenCode) edit files directly via ACP protocol, bypassing Avante's conflict marker system
  - **Confirmed Working:** Solution (`auto_approve_tool_permissions = false`) only works with traditional providers (Copilot, Claude API), NOT with ACP
  - **Status:** Both issues still open, 26+ and 7+ people affected respectively (as of 2025-11-19)
  - **Workaround:** Use git workflow (commit → let AI work → `git diff` to review changes)
  - **Alternative:** Switch to Copilot provider (confirmed working with diff review, but requires separate subscription)
  - **Action:** Check back periodically for fix - shouldn't be too difficult to solve, just needs ACP-specific handling
- [ ] Configure additional LSPs as needed (JavaScript/TypeScript, Python, Rust)
- [ ] Learn LazyVim keybindings and best practices
- [ ] Set up project-specific configurations
- [ ] Configure debugging (DAP)

### 🖥️ Hyprland Configuration
- [ ] Set up workspace rules and assignments
- [ ] Configure window rules for specific apps
- [ ] Configure gestures (if using touchpad)
- [ ] Set up special workspaces/scratchpads

### 🎨 Theming & Appearance
- [ ] Choose and download wallpapers to ~/pics/wallpapers/
- [ ] Set GTK theme to match Base2Tone Field Dark
- [ ] Set Qt theme to match
- [ ] Configure cursor theme

### 🔧 System Configuration
- [x] Set up dotfiles management (GNU Stow - see ~/dotfiles/)
- [ ] Configure backup strategy
- [ ] Set up system maintenance scripts
- [ ] Configure firewall (ufw or iptables)
- [x] Configure SSH for connection multiplexing and keep-alives

### 📦 Package Management
- [ ] Configure paru colors for better readability
- [ ] Document installed packages for backup

### 🌐 Browser & Apps
- [ ] Firefox extensions setup
- [ ] Sync Firefox settings from Mac
- [x] Install yazi TUI file manager with preview tools

### 🚀 Future Enhancements
- [ ] Password manager integration
- [ ] Chat applications (Discord, Slack, etc.)
- [ ] Set up rofi/wofi alternatives if needed

---

## Quick Reference

### Installed Locations

**⚠️ Important:** After applying GNU Stow, all configs will be symlinks to `~/dotfiles/`.
Edit files in `~/dotfiles/` to modify your active configuration.

**Current (before stow):**
- Hyprland config: `~/.config/hypr/`
- Waybar config: `~/.config/waybar/`
- Kitty config: `~/.config/kitty/`
- Neovim config: `~/.config/nvim/`
- Yazi config: `~/.config/yazi/`
- Fuzzel config: `~/.config/fuzzel/`
- Mako config: `~/.config/mako/`
- Mise config: `~/.config/mise/`
- Starship config: `~/.config/starship.toml`
- Zsh config: `~/.zshrc`
- Git config: `~/.gitconfig`
- SSH config: `~/.ssh/config`

**After stow:**
- All configs: `~/dotfiles/package-name/.config/...` (symlinked to active locations)

### Key Files
- `~/.config/hypr/hyprland.conf` - Main Hyprland configuration
- `~/.config/hypr/hypridle.conf` - Idle management
- `~/.config/hypr/hyprlock.conf` - Lock screen
- `~/.config/kitty/current-theme.conf` - Kitty theme (Base2Tone Field Dark)
- `~/.config/waybar/config.jsonc` - Waybar configuration
- `~/.config/waybar/style.css` - Waybar styling

### Important Commands
- Reload Hyprland: `hyprctl reload` or `SUPER + Shift + R`
- Reload Waybar: `killall waybar && waybar &`
- Reload Kitty config: `Ctrl + Shift + F5`
- Reload Zsh: `source ~/.zshrc`
- Edit Hyprland config: `nvim ~/.config/hypr/hyprland.conf`

---

## System Notes

**Power Management:** 5min→lock, 7min→display off, 10min→suspend, lid close→suspend

**Dual Monitor:** Laptop 2.0x scale, External 4K 1.5x scale, Firefox set to 1.5 globally

**Keyboards:** Per-device configs - Laptop uses keyd (Caps: tap=Esc, hold=Ctrl), ZSA Voyager uses firmware remapping

**Hardware:** Slimbook EVO14-AI9-STP with AMD Ryzen AI 9 365 (Strix Point) - added official Slimbook repo for hardware-specific fixes

---

## Color Scheme: Base2Tone Field Dark

**Theme:** Duotone - Teal/Turquoise and Bright Field Green

**Colors:**
- Background: `#18201e` (dark greenish-black)
- Foreground: `#8ea4a0` (muted teal-gray)
- Green: `#3be381`, `#55ec94` (bright field green)
- Teal/Cyan: `#25d0b4`, `#40ddc3`, `#88f2e0`
- Yellow: `#85ffb8` (light green)
- Red: `#ff6b6b` (contrasting red for errors)

Consistent across Kitty terminal and Starship prompt.

---

## Recent Changes

**2025-11-22:**
- **System updates:** Full system upgrade (paru -Syu), fixed imv broken dependency
- **Node.js:** Installed v24.11.1 LTS via mise
- **Yazi TUI file manager:**
  - Full configuration with Base2Tone Field Dark theme
  - Vim-style keybindings (hjkl, gg, G, etc.)
  - File openers configured (nvim, imv, mpv, firefox)
  - Preview tools installed (imv, chafa, ffmpegthumbnailer, jq, imagemagick)
  - Added ya() function to .zshrc for cd-on-exit
- **Zsh enhancements:**
  - Comprehensive aliases for modern CLI tools (eza, bat, fd, rg, zoxide)
  - Git aliases (gaa, gcm, gd, glog, gp, gl, etc.)
  - FZF integration with bat previews
  - SSH agent auto-start
  - Navigation aliases (.., ..., cd→z)
- **SSH & Git:**
  - Migrated SSH keys from macOS (id_ed25519 + id_rsa)
  - Created ~/.ssh/config with GitHub/GitLab shortcuts, multiplexing, keep-alives
  - Configured git globally (user: jstcz, email: j.czepluch@proton.me)
  - Git aliases configured (st, co, br, lg, etc.)
  - Default branch: main, SSH URLs for GitHub
  - Tested successfully with GitHub
- **GNU Stow setup:**
  - Created ~/dotfiles/ repository
  - Organized all configs into stow packages (12 packages total)
  - Added fuzzel, mako, mise configs
  - Committed all configs (commit 46f3dee)
  - Created STOW_SETUP.md guide
  - **Not yet applied:** Configs still in original locations, need to stow
  - **Not yet pushed:** Requires SSH passphrase to push to GitHub
- **Dotfiles packages ready:**
  - zsh, starship, git, ssh, hypr, waybar, kitty, nvim, yazi, fuzzel, mako, mise

**2025-11-19:**
- Fixed critical keyboard suspend/resume issue
- Identified root cause: i8042 controller on Slimbook EVO with Strix Point CPU
- Added Slimbook official Arch repository
- Installed hardware-specific UDEV quirk packages (`slimbook-quirk-i8042-wakeup`, `slimbook-quirk-i8042-reset`)
- Neovim: Added `jk` as escape mapping in insert mode
- Documented external keyboard input lag issue (ZSA Voyager)
- Fuzzel: Disabled icons, matched Base2Tone Field Dark theme
- Changed launcher keybinding: SUPER+D → SUPER+Space
- keyd setup: Caps Lock tap=Esc, hold=Ctrl (laptop keyboard only)
- **Avante.nvim: Configured to use OpenCode via ACP**
  - Uses Claude Pro/Max subscription via OAuth (no API key needed!)
  - Can use any model/provider OpenCode supports (75+ providers)
  - No Node.js bridge dependencies - native ACP support
  - OpenCode already installed (v1.0.78) and authenticated
  - **Known Issue:** Inline diff review not working with ACP providers
  - **Issue links:** https://github.com/yetone/avante.nvim/issues/2689 and https://github.com/yetone/avante.nvim/issues/2750
  - **Current Status:** Functional for chat/code generation, but ACP agents bypass conflict marker system
  - **Temp Workflow:** Use git commits to review changes (`git add -A && git commit -m "checkpoint"` before session, then `git diff` after AI edits)

**2025-11-14:**
- Dual monitor setup: Laptop 2.0x, External 4K 1.5x scaling
- Vim-style keybindings: SUPER+h/j/k/l for navigation, SUPER+Shift+h/j/k/l for moving windows
- Waybar redesigned with unified Base2Tone Field Dark green theme
- Firefox scaling fixed (set to 1.5 in about:config)
- Per-device keyboard configs (Caps→Esc on laptop only)
- Neovim: Default 4-space indent with ftplugin overrides for JS/TS/JSON/YAML
- hyprpaper configured and ready for wallpapers

**2025-11-13:**
- Neovim setup: Gleam & Solidity treesitter, formatters (via conform.nvim), LSPs
- Installed Gleam 1.13.0 and Foundry 1.4.4 via mise
- Outstanding: Solidity LSP diagnostics not working (try `solidity_ls` next)

---

---

## Dotfiles Repository

**Location:** `~/dotfiles/`  
**GitHub:** `git@github.com:czepluch/dotfiles.git`  
**Status:** 
- ✅ All configs committed (12 packages)
- ⚠️ Not yet pushed to GitHub
- ❌ Stow not yet applied

**See:** `~/dotfiles/STOW_SETUP.md` for complete setup instructions

**Packages:** zsh, starship, git, ssh, hypr, waybar, kitty, nvim, yazi, fuzzel, mako, mise

---

*Last updated: 2025-11-22*

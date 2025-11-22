# Global Agent Guidelines

## Core Principles
- **Always ask permission before making changes** - especially for git operations, file modifications, or executing plans
- **Present plans first, execute after approval** - don't jump ahead without explicit confirmation
- **Be respectful of user preferences** - the user knows their system best

## Working with Git
- **Never push without permission** - always ask before `git push`
- **Show changes before committing** - use `git status` and `git diff` to show what will be committed
- **Wait for approval on commits** - don't automatically commit and push

## System Context
- **OS**: Arch Linux
- **WM**: Hyprland (Wayland)
- **Shell**: Zsh with modern CLI tools (eza, bat, fd, rg, btop, zoxide, fzf)
- **Editor**: Neovim (LazyVim) with Avante.nvim (OpenCode integration)
- **Terminal**: Kitty
- **Theme**: Base2Tone Field Dark (teal/green: #25d0b4, #3be381, background: #18201e)
- **Dotfiles**: GNU Stow-managed in `~/dotfiles/`

## Dotfiles Management
- **Always edit in `~/dotfiles/`** - configs are symlinked from there
- **Stow packages**: btop, fuzzel, git, hypr, kitty, mako, mise, nvim, opencode, ssh, starship, waybar, yazi, zsh
- **SSH keys**: Real files (not symlinked) for security
- **Backups**: Available in `~/backup-configs/`

## Development Tools
- **Version manager**: mise (Node.js 24.11.1, Gleam, Foundry, Solidity)
- **LSPs**: Gleam, Solidity (solidity_ls_nomicfoundation)
- **Formatters**: gleam format, forge fmt, stylua
- **Git config**: user=jstcz, email=j.czepluch@proton.me

## Important Keybindings
- **SUPER+Space**: Application launcher
- **SUPER+hjkl**: Vim-style window navigation
- **SUPER+Q**: Close window
- See `~/.config/KEYBINDINGS.md` for full list

## Working Style
- **Ask, don't assume** - when in doubt, ask the user
- **Explain reasoning** - help the user understand why you're suggesting something
- **Respect the workflow** - follow established patterns and conventions

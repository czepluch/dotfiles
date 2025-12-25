# Global Agent Guidelines

## Core Principles
- **Always ask permission before making changes** - especially for git operations, file modifications, or executing plans
- **Present plans first, execute after approval** - don't jump ahead without explicit confirmation
- **Be respectful of user preferences** - the user knows their system best
- If the user asks a question, then just answer the question. Don't go ahead and start implementing things. You can provide suggested next steps or a plan for how to tackle the things in the question
- Never make assumptions about tools installed. Always verify your theories. If you are unsure which neovim plugin is used for something specific either look at the config and find out or ask the user. Never make assumptions.
- Use the internet for research too, be thorough
- Consult the official documentation of projects you're working with when trying to find solutions -- often they clearly show how to use APIs and config files.
- If you're uncertain about something while working, stop and ask the user for advice. It's a waste of everyone's time to just assume things.

## Working with Git
- **Never push without permission** - always ask before `git push`
- Don't commit without permission either. ALWAYS get the user's approval that the work you've done is as expected before committing.
- **Show changes before committing** - use `git status` and `git diff` to show what will be committed
- **Wait for approval on commits** - don't automatically commit and push

## System Context
- **Shell**: Zsh with modern CLI tools (eza, bat, fd, rg, btop, zoxide, fzf)
- **Editor**: Neovim (LazyVim) with Avante.nvim (OpenCode integration)
- **Terminal**: Kitty
- **Theme**: Base2Tone Field Dark (teal/green: #25d0b4, #3be381, background: #18201e)
- **Dotfiles**: GNU Stow-managed in `~/dotfiles/`

## Dotfiles Management
- **Always edit in `~/dotfiles/`** - configs are symlinked from there
- **Stow packages**: btop, fuzzel, git, hypr, kitty, mako, mise, nvim, opencode, ssh, starship, waybar, yazi, zsh

## Working Style
- **Ask, don't assume** - when in doubt, ask the user
- **Explain reasoning** - help the user understand why you're suggesting something
- **Respect the workflow** - follow established patterns and conventions

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# History options
setopt appendhistory          # Append to history file, don't overwrite
setopt inc_append_history     # Write to history file immediately, not on shell exit
setopt share_history          # Share history between all sessions
setopt hist_ignore_dups       # Don't record duplicate entries
setopt hist_ignore_all_dups   # Delete old duplicate entries
setopt hist_find_no_dups      # Don't display duplicates when searching
setopt hist_ignore_space      # Don't record commands starting with space
setopt hist_save_no_dups      # Don't write duplicate entries to history file
setopt hist_reduce_blanks     # Remove superfluous blanks from history
setopt hist_verify            # Show command with history expansion before running it

# Include hidden files in tab completion
setopt globdots

# History search with arrow keys
# Type a few letters and press up/down to search history starting with those letters
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search    # Up arrow
bindkey "^[[B" down-line-or-beginning-search  # Down arrow

# Completions
# Enable zsh-completions (250+ additional completion definitions)
fpath=(/usr/share/zsh/site-functions $fpath)
autoload -Uz compinit
compinit

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Default app
export EDITOR=nvim
export VISUAL=nvim

# Modern CLI tool replacements
alias ls='eza --icons'
alias ll='eza -la --icons'
alias la='eza -a --icons'
alias lt='eza --tree --level=2 --icons'
alias l='eza -lah --icons'
alias cat='bat'
alias batp='bat --paging=always'
alias find='fd'
alias grep='rg'
alias htop='btop'
alias vim='nvim'
alias v='nvim'

# Eza with git status
alias lsg='eza -la --icons --git'
alias lsgg='eza -la --icons --git --git-ignore'

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias gs='git status'
alias gst='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'
alias glg='lazygit'

# Config editing
alias zrc='nvim ~/.zshrc'
alias zsrc='source ~/.zshrc'
alias hyprconf='nvim ~/.config/hypr/hyprland.conf'
alias nvimconf='cd ~/.config/nvim && nvim'

# Quick directory jumps (customize to your frequent dirs)
alias dev='cd ~/dev'
alias dots='cd ~/.config'
alias dl='cd ~/Downloads'

# System
alias ports='netstat -tulanp'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias df='df -h'
alias free='free -h'
alias update='paru -Syu'
alias cleanup='paru -Sc --noconfirm'

# FZF enhanced commands
# Preview files with bat, directories with eza
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# Ripgrep with fzf
alias rgf='rg --files | fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'  # Go back to previous directory

# Zoxide aliases (smart cd replacement)
# After sourcing zoxide below, 'z' and 'zi' will be available
# z <directory> - jump to directory
# zi - interactive directory picker with fzf
alias cd='z'  # Use zoxide instead of cd

# Yazi - change directory on exit
function ya() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# SSH agent - start and load key
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  eval "$(ssh-agent -s)" > /dev/null
fi
ssh-add ~/.ssh/id_ed25519 2>/dev/null

# Mise (version manager)
eval "$(mise activate zsh)"

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# Starship prompt
eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"

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

# Detect OS
OS_TYPE="$(uname -s)"

# Completions
# Enable zsh-completions (250+ additional completion definitions)
if [[ "$OS_TYPE" == "Darwin" ]]; then
  # macOS (Homebrew)
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
else
  # Linux (system packages)
  fpath=(/usr/share/zsh/site-functions $fpath)
fi
autoload -Uz compinit
compinit

# Plugins
if [[ "$OS_TYPE" == "Darwin" ]]; then
  # macOS (Homebrew paths)
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
  # Linux (system paths)
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

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
alias nvimconf='cd ~/.config/nvim && nvim'
# Linux-specific config aliases
if [[ "$OS_TYPE" != "Darwin" ]]; then
  alias hyprconf='nvim ~/.config/hypr/hyprland.conf'
fi

# Quick directory jumps (customize to your frequent dirs)
alias dev='cd ~/dev'
alias dots='cd ~/.config'
alias dl='cd ~/Downloads'

# System
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias df='df -h'

# OS-specific system commands
if [[ "$OS_TYPE" == "Darwin" ]]; then
  # macOS
  alias ports='sudo lsof -iTCP -sTCP:LISTEN -n -P'
  alias update='brew update && brew upgrade'
  alias cleanup='brew cleanup'
else
  # Linux
  alias ports='netstat -tulanp'
  alias free='free -h'
  alias update='paru -Syu'
  alias cleanup='paru -Sc --noconfirm'
fi

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


# Application aliases
alias oo="opencode"
alias t="task"

# WireGuard VPN (DAppNode)
alias vpn-home='sudo wg-quick up dappnode-local'
alias vpn-remote='sudo wg-quick up dappnode-remote'
alias vpn-down='sudo wg-quick down dappnode-local 2>/dev/null; sudo wg-quick down dappnode-remote 2>/dev/null'
alias vpn-status='sudo wg show'

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

# SSH agent - Linux only (macOS handles this automatically)
if [[ "$OS_TYPE" != "Darwin" ]]; then
  # Linux: use keychain for persistence across sessions
  # --nogui: prompt in terminal instead of GUI
  if command -v keychain &> /dev/null; then
    eval $(keychain --eval --nogui --quiet id_ed25519)
  fi
fi

# Mise (version manager)
eval "$(mise activate zsh)"

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# Starship prompt
eval "$(starship init zsh)"

# Add cargo binaries to PATH
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Improved history search (Ctrl+R with fzf)
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --color header:italic
  --header 'Press CTRL-/ to toggle preview'"

# Better directory colors for macOS
if [[ "$OS_TYPE" == "Darwin" ]]; then
  export CLICOLOR=1
  export LSCOLORS=GxFxCxDxBxegedabagaced
fi

# Helpful functions
# Extract any archive type
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick backup of a file
bak() {
  cp "$1" "$1.bak-$(date +%Y%m%d-%H%M%S)"
}

# Find and kill process by name
fkill() {
  local pid
  pid=$(ps aux | grep -v grep | grep "$1" | fzf | awk '{print $2}')
  if [ -n "$pid" ]; then
    kill -9 "$pid"
    echo "Killed process $pid"
  fi
}

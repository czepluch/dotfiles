
# Added by Radicle.
export PATH="$PATH:/home/jacob/.radicle/bin"

# elan (Lean toolchain). Must live here, not .zprofile: .zprofile does
# `exec start-hyprland` before reaching its PATH exports, so anything set after
# that exec never runs in the graphical session. .zshenv is sourced by every zsh
# invocation and before .zprofile, so Hyprland inherits this through the exec.
if [ -d "$HOME/.elan/bin" ]; then
  export PATH="$HOME/.elan/bin:$PATH"
fi

# Fe toolchain
if [ -f "$HOME/.fe/env" ]; then
  . "$HOME/.fe/env"
fi

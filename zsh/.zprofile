if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec start-hyprland
fi

# NOTE: do not add PATH exports below the `exec` above - it replaces this
# process, so nothing here runs in the graphical session. PATH lives in .zshenv.

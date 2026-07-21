# Hyprland Lua cutover checklist

Transient doc - delete once the Lua config is confirmed good. The old `hyprland.conf`
is kept as an instant rollback until then.

## State right now

- `hyprland.lua` + `lua/*.lua` are staged in `~/.config/hypr/` but **inert**: Hyprland
  picks conf-vs-lua **once at startup**, so the running session still uses
  `hyprland.conf`. `hyprctl reload` will NOT switch formats - only a relogin does.
- Offline-validated: every file parses under Lua 5.4 and the whole config loads under a
  mock `hl` API (5 monitors, 73 binds, 11 autostart spawns, submap + notification OK).
- Not yet verified: Hyprland's live acceptance of a few dispatcher/rule argument shapes
  (see the spot-check list). These are documented in the wiki but unproven on this box.

## Activate

1. Log out and back in (or restart Hyprland). This ends the terminal/Claude session.
2. Borders will be the **fallback** cyan/green until you run the theme engine:
   `theme-set <your-current-palette>`  (generates `hypr-colors.lua` + repaints live).

## Rollback (if anything is wrong)

    mv ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua.disabled
    # log out and back in -> Hyprland falls back to hyprland.conf

(The files live in the dotfiles repo via the symlinked dir; renaming the entry is enough
to deactivate without losing the work.)

## Live spot-check (things offline tests can't prove)

- [ ] `theme-set <palette>` -> active border gradient + inactive border correct; apps NOT
      relaunched; `git -C ~/dotfiles status` stays clean.
- [ ] Clipboard: SUPER+C / V / X copy/paste/cut in a terminal (native `send_shortcut`).
- [ ] SUPER+SHIFT+[1-0] moves the window to that workspace but **stays** on the current
      one (the `follow = false` = "silent" behaviour).
- [ ] Arrow-key resize grows/shrinks by a delta (the `relative = true` fix).
- [ ] SUPER+CTRL+h / l moves the current workspace to the other monitor.
- [ ] Autostart: element->ws5, firefox->ws2, scratchpad terminal->special:magic (all
      silent), plus waybar / hypridle / hyprpaper / sunsetr up.
- [ ] Scratchpad (SUPER+S) shows the rainbow border (the `border_color` string rule).
- [ ] SUPER+M -> session notification; l lock / e logout / s suspend / r reboot /
      p poweroff / Escape cancel.
- [ ] Waybar + mako blur; 3-finger horizontal swipe switches workspaces.
- [ ] Idle path: wait out hypridle (or `~/.config/hypr/scripts/idle-warn.sh start` then
      `stop`) -> red border on warn, themed border restored on wake, no app relaunch.

## After it's confirmed good (cleanup)

- Remove `hyprland.conf` and `themes/templates/hyprland.conf.tpl` (the old sourced color
  file `~/.config/themes/current/hyprland.conf` also becomes orphaned).
- Delete this file, then commit.

-- Keybindings. Migrated from hyprland.conf.
-- Native-Lua upgrades vs the old config: workspace binds are a loop, SUPER+M is now a
-- fuzzel session menu (scripts/power-menu.sh), and dispatchers are native
-- (no `exec, hyprctl dispatch ...` except the clipboard sendshortcut, see note).

local mainMod = "SUPER"

-- Programs (were $terminal / $fileManager / $menu)
local terminal    = "ghostty"
local fileManager = "dolphin"
local menu        = "fuzzel"

--------------------------------------------------------------------------------
-- Core
--------------------------------------------------------------------------------
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind("CTRL + " .. mainMod .. " + Q", hl.dsp.exec_cmd("hyprlock")) -- lock screen
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())              -- dwindle
hl.bind(mainMod .. " + T",      hl.dsp.layout("togglesplit"))        -- dwindle
hl.bind(mainMod .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W",      hl.dsp.exec_cmd("~/dotfiles/themes/bin/theme-wallpaper --browse"), { description = "Wallpaper browser" })
hl.bind(mainMod .. " + N",      hl.dsp.exec_cmd("~/.config/waybar/dnd.sh toggle")) -- DND (script toasts state)
hl.bind(mainMod .. " + A",      hl.dsp.exec_cmd("~/.local/bin/husk-capture"), { description = "Quick task capture (husk)" }) -- full path: ~/.local/bin is not on Hyprland's PATH

--------------------------------------------------------------------------------
-- Universal clipboard via Insert shortcuts (works in terminals). SUPER+C/V/X.
-- Runs send_shortcut through hyprctl, outside the bind handler. Called directly,
-- it leaves the key logically held in the client, so the client auto-repeats it
-- and holding Shift afterwards repeats the paste.
--------------------------------------------------------------------------------
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd([[hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" })']]))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd([[hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" })']]))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd([[hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL", key = "X" })']]))

-- Clipboard manager
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

--------------------------------------------------------------------------------
-- Focus / move / resize
--------------------------------------------------------------------------------
-- Move focus (vim keys)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Resize active (arrow keys)
hl.bind(mainMod .. " + left",  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }))
hl.bind(mainMod .. " + right", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }))
hl.bind(mainMod .. " + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }))
hl.bind(mainMod .. " + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }))

-- Move active window (vim keys)
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

-- Move current workspace to another monitor (relative)
hl.bind(mainMod .. " + CTRL + h", hl.dsp.workspace.move({ monitor = "-1" }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.workspace.move({ monitor = "+1" }))

--------------------------------------------------------------------------------
-- Workspaces 1-10: SUPER+N = switch, SUPER+SHIFT+N = move active window (silent)
--------------------------------------------------------------------------------
for i = 1, 10 do
  local key = i % 10 -- 10 -> "0"
  hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", follow = false }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------------------------------------------------------
-- Multimedia (locked = works on lock screen; repeating = held-key repeat)
--------------------------------------------------------------------------------
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n1 set 5%+"),                   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n1 set 5%-"),                   { locked = true, repeating = true })

-- Media keys (requires playerctl; locked = works on lock screen)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------------------------------------------------------
-- Screenshots (region / full / active window) -> ~/pics/scrots/ + clipboard
--------------------------------------------------------------------------------
hl.bind("Print",         hl.dsp.exec_cmd([[grim -g "$(slurp)" - | tee ~/pics/scrots/$(date +'%Y-%m-%d_%H-%M-%S.png') | wl-copy]]))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[grim - | tee ~/pics/scrots/$(date +'%Y-%m-%d_%H-%M-%S.png') | wl-copy]]))
hl.bind("ALT + Print",   hl.dsp.exec_cmd([[grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | tee ~/pics/scrots/$(date +'%Y-%m-%d_%H-%M-%S.png') | wl-copy]]))

--------------------------------------------------------------------------------
-- Session / power menu (replaces the old SUPER+M = exit). Fuzzel dmenu, themed
-- by the theme system; entries execute immediately, Escape cancels.
--------------------------------------------------------------------------------
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/power-menu.sh"), { description = "Session menu" })

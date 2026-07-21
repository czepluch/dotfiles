-- Keybindings. Migrated from hyprland.conf.
-- Native-Lua upgrades vs the old config: workspace binds are a loop, SUPER+M is now a
-- session/power submap, and dispatchers are native (no `exec, hyprctl dispatch ...`
-- except the clipboard sendshortcut, see note).

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
hl.bind(mainMod .. " + N",      hl.dsp.exec_cmd("~/.config/waybar/dnd.sh toggle")) -- DND (script toasts state)

--------------------------------------------------------------------------------
-- Universal clipboard via Insert shortcuts (works in terminals). SUPER+C/V/X.
-- Native send_shortcut dispatcher; window defaults to the active window.
--------------------------------------------------------------------------------
hl.bind(mainMod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL",  key = "Insert" }))
hl.bind(mainMod .. " + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))
hl.bind(mainMod .. " + X", hl.dsp.send_shortcut({ mods = "CTRL",  key = "X" }))

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
-- Session / power submap (replaces the old SUPER+M = exit).
-- The "reset" second arg auto-closes the submap back to the global keymap after ANY
-- action fires, so e.g. lock returns you to normal mode on unlock. Escape/catchall also
-- reset explicitly so a stray key can never strand you inside the submap.
--------------------------------------------------------------------------------
hl.define_submap("session", "reset", function()
  hl.bind("l", hl.dsp.exec_cmd("hyprlock"))           -- lock
  hl.bind("e", hl.dsp.exit())                         -- exit Hyprland (logout)
  hl.bind("s", hl.dsp.exec_cmd("systemctl suspend"))  -- suspend
  hl.bind("r", hl.dsp.exec_cmd("systemctl reboot"))   -- reboot
  hl.bind("p", hl.dsp.exec_cmd("systemctl poweroff")) -- poweroff
  hl.bind("Escape",   hl.dsp.submap("reset"))         -- leave
  hl.bind("catchall", hl.dsp.submap("reset"))         -- any other key leaves
end)
hl.bind(mainMod .. " + M", hl.dsp.submap("session"), { description = "Session menu" })

-- Native notification when a non-global submap is entered.
hl.on("keybinds.submap", function(name)
  if name and name ~= "" then
    hl.notification.create({
      text     = "session: [l] lock  [e] logout  [s] suspend  [r] reboot  [p] poweroff  [esc] cancel",
      timeout  = 5000,
      icon     = "info",
    })
  end
end)

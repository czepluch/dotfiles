-- Autostart. Registered on the "hyprland.start" event, which fires once at compositor
-- start and NOT on `hyprctl reload` - so a reload (e.g. idle-warn.sh restoring the
-- border, or a theme switch) never relaunches these. See
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

local element  = "element-desktop --password-store=gnome-libsecret"
local browser  = "firefox"
local terminal = "ghostty"

hl.on("hyprland.start", function()
  -- Push compositor env into the systemd user manager so managed units (polkit,
  -- waybar) find the Wayland socket reliably at login.
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP")
  hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("systemctl --user start --no-block waybar.service")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("wl-paste --watch cliphist store")
  hl.exec_cmd("sunsetr --background")
  hl.exec_cmd("hyprpaper")

  -- Apps pinned to specific workspaces, launched silently (don't follow focus).
  hl.exec_cmd(element,  { workspace = "5 silent" })
  hl.exec_cmd(browser,  { workspace = "2 silent" })
  hl.exec_cmd(terminal, { workspace = "special:magic silent" })
end)

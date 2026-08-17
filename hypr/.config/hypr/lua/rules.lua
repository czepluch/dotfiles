-- Window rules. See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Ignore maximize requests from all apps
hl.window_rule({
  name  = "suppress-maximize",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix dragging issues with XWayland
hl.window_rule({
  name  = "fix-xwayland-drags",
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
  no_focus = true,
})

-- Wallpaper browser (theme-wallpaper --browse, SUPER+W): floating centered
-- yazi window with image previews
hl.window_rule({
  name  = "wallpaper-browser",
  match = { class = "wallpaper.browser" },
  float = true,
  size  = "55% 60%",
  center = true,
})

-- Rainbow border for the magic special workspace (active = ROYGBIV, inactive = muted).
-- Verbatim port of the original two-gradient string (active 7-stop @0deg + inactive
-- 2-stop @0deg). The wiki confirms border_color accepts a color/gradient string.
hl.window_rule({
  name  = "magic-rainbow-border",
  match = { workspace = "special:magic" },
  border_color = "rgb(ff0040) rgb(ff8000) rgb(ffff00) rgb(00ff40) rgb(00d4ff) rgb(7f3fff) rgb(ff00ff) 0deg rgb(444444) rgb(666666) 0deg",
})

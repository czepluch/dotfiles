-- Input, gestures, and per-device keyboard config.

hl.config({
  input = {
    kb_layout  = "us,dk",
    -- altgr-intl: US base unchanged; RAlt+z/w/l = ae/aa/oe, Shift+RAlt = Compose
    kb_options = "grp:alt_shift_toggle,lv3:ralt_switch_multikey",
    kb_variant = "altgr-intl,",
    kb_model   = "",
    kb_rules   = "",

    follow_mouse = 1,
    sensitivity  = 0, -- -1.0 .. 1.0, 0 = unmodified

    touchpad = {
      natural_scroll       = true,
      clickfinger_behavior = true,
    },
  },
})

-- 3-finger horizontal swipe = switch workspace
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Laptop keyboard: Caps handled by keyd (tap=Esc, hold=Ctrl)
hl.device({
  name       = "at-translated-set-2-keyboard",
  kb_variant = "altgr-intl,",
  kb_options = "grp:alt_shift_toggle,lv3:ralt_switch_multikey",
})

-- ZSA Voyager: firmware already remaps
hl.device({
  name       = "zsa-technology-labs-voyager-keyboard",
  kb_variant = "altgr-intl,",
  kb_options = "grp:alt_shift_toggle,lv3:ralt_switch_multikey",
})

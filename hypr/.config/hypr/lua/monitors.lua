-- Monitors. See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Laptop eDP-1 is the fallback when externals are disconnected; the desc-matched
-- externals attach whichever are physically present (HOME / COWORK docks).

-- Laptop display (effective 1920x1200 @ 1.0)
hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 1.0 })

-- HOME: AORUS FO32U2P 4K 240Hz - right of the laptop's effective width
hl.monitor({ output = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. AORUS FO32U2P", mode = "3840x2160@240", position = "1920x0", scale = 1 })

-- COWORK: Gigabyte M32U 4K 120Hz (center)
hl.monitor({ output = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. Gigabyte M32U", mode = "3840x2160@120", position = "1920x0", scale = 1 })

-- COWORK: Dell U2719DC QHD - right of M32U, rotated clockwise
hl.monitor({ output = "desc:Dell Inc. DELL U2719DC", mode = "2560x1440@60", position = "5760x0", scale = 1, transform = 1 })

-- Fallback for any other monitor
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

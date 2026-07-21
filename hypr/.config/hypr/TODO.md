# Hyprland config - follow-up TODO

Deferred items from the Lua migration (see `~/.claude/plans/` migration plan). These were
discussed but intentionally left out of the Lua migration pass. Not blocking.

## 1. hyprlock blur race on lid-close / wake  (hyprlock + hypridle, NOT the Lua migration)

**Symptom:** Closing the lid locks correctly (hyprlock starts), but hyprlock's blur is not
applied in time. On re-opening the lid there is a split-second where the pre-lock screen
content is visible before hyprlock's blurred lock surface finishes drawing.

**Nature:** A render/DPMS timing race - the display powers back on before hyprlock's first
(blurred) frame is ready. This lives in `hyprlock.conf` / `hypridle.conf` (both stay
hyprlang), so it is independent of the compositor Lua rewrite.

**Directions to investigate:**
- `hyprlock` background is a live screenshot + blur; capture+blur has latency. Try
  rendering-ahead, `hide_cursor`, or eliminating the capture delay (static image/solid
  color background) as an A/B test to confirm the capture step is the culprit.
- Ordering in `hypridle.conf`: `before_sleep_cmd = loginctl lock-session` must fully bring
  hyprlock up before suspend/DPMS-off. Consider `inhibit_sleep`, a short pre-suspend delay,
  or `lock_cmd` tuning so the first frame is drawn before the panel powers down.
- On wake, keep the internal panel DPMS-off until hyprlock signals its first frame, rather
  than powering on into a stale framebuffer.
- Check the installed `hyprlock` version against upstream for first-frame / immediate-render
  fixes; this has seen upstream churn.

## 2. Workspace -> monitor pinning for HOME / COWORK docks

Pin workspaces to specific monitors by `desc:` so a given workspace always lands on the
right screen when docked. Declarative baseline via `hl.workspace_rule({ workspace=...,
monitor="desc:..." })`. Optional: event-driven reflow on hotplug via
`hl.on("monitor.added" / "monitor.removed", ...)` (genuinely Lua-only, more moving parts).
Monitors currently connected: AORUS FO32U2P (HOME), Gigabyte M32U + Dell U2719DC (COWORK).

## 3. (Optional) Lid switch bind, if ever wanted

Hyprland supports `switch:on:Lid Switch` binds in Lua (`hl.bind("switch:on:Lid Switch",
...)`). Not needed for item 1 (locking already works), but noted here as an available hook
if lid behavior ever needs compositor-level control (e.g. per-dock DPMS toggling).

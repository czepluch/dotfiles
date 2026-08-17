# Theme System Specification

Centralized color management for all desktop applications: one palette file
in, every app's colors out. Rendered by matugen (Tera templates), orchestrated
by `theme-set` / `theme-apply`.

Core guarantee: **switching palettes never touches a git-tracked file.**
Everything a switch writes lands under `~/.config/themes/`. Acceptance test:
`theme-set <a> && theme-set <b>` must leave `git -C ~/dotfiles status` exactly
as it was. (One documented exception: nvim's `lazy-lock.json` changes the
first time a palette introduces a colorscheme plugin that was never installed
before - a one-time event per plugin, not per switch.)

## Pipeline

```
palettes/<name>.toml
    | theme-set: cp to colors.toml
    v
colors.toml  --bin/palette-to-json-->  ~/.config/themes/current/palette.json
    | matugen --config matugen.toml json palette.json
    v
templates/*.tera  --render-->  ~/.config/themes/.staging/
    | theme-apply: mv -f per file (atomic rename)
    v
~/.config/themes/current/*  <--symlinks/imports-- apps
```

- **palette-to-json** validates the 22 color keys, then derives everything
  the templates may reference: 13 named aliases, `gradient1..gradient9`
  (accent to magenta lerp), and a `<key>_vivid` variant for every key
  (saturation push away from the channel mean). All integer math matches the
  retired bash engine bit-for-bit (division truncates toward zero).
- **matugen** (pinned expectation: 4.1.0, Arch `extra`) imports the palette
  verbatim via `import_json_files` - no Material You harmonization. Rendering
  is all-or-nothing: any template error aborts the run with a precise message
  and the staging never reaches `current/`, so a broken edit can never leave
  a half-applied theme.
- **Atomic swap**: staging and `current/` share a filesystem, so each `mv` is
  a `rename(2)` - no app can ever observe a half-written file.

## colors.toml Format

22 color keys plus an optional wallpaper path:

```toml
accent = "#89b4fa"
cursor = "#f5e0dc"
foreground = "#cdd6f4"
background = "#1e1e2e"
selection_foreground = "#1e1e2e"
selection_background = "#f5e0dc"
color0 = "#45475a"     # through color15

wallpaper = "~/pics/wallpapers/foo.jpg"  # optional
```

## Template Variable Syntax (Tera)

| Syntax | Output |
|--------|--------|
| `{{ colors.accent.default.hex }}` | `#89b4fa` |
| `{{ colors.accent.default.hex_stripped }}` | `89b4fa` |
| `{{ colors.accent.default.red }}` (also `.green`, `.blue`) | `137` (decimal) |
| `{{ colors.accent_vivid.default.hex }}` | saturation-boosted variant |

Alpha is literal text after the placeholder: `#{{ ...hex_stripped }}60`.
Bare `r, g, b` values are built from the three channel accessors (matugen's
own `.rgb` renders wrapped as `rgb(r, g, b)` - not used).

Named aliases (derived by palette-to-json, usable as `colors.red...` etc.):
red=color1, green=color2, yellow=color3, blue=color4, magenta=color5,
cyan=color6, white=color7, bright_red=color9 through bright_cyan=color14.

**Backslash rule**: matugen's Tera collapses `\\` to `\` in raw template
text. Any literal backslash in a template must be written doubled. This
matters mainly in `starship.toml.tera` (format-block line continuations and
`\\[ \\]` escapes) - when editing prompt config there, write `\\` for every
`\` you want in the output.

## Consumption Patterns

### A - Import Fragment
App config adds one source/import line pointing at generated output.
- **ghostty**: `config-file = ~/.config/themes/current/ghostty.conf`
- **hyprland**: `hyprland.lua` does `pcall(dofile, ".../hypr-colors.lua")`
  with an inline fallback; the generated file returns a Lua table
- **hyprlock**: `source = ...` under `# hyprlang noerror true/false`; the
  generated file defines every `$var` the lockscreen body consumes
- **btop**: `color_theme` points at `~/.config/btop/themes/current.theme`,
  a committed symlink into `themes/current/`
- **newt** (nmtui/whiptail): `NEWT_COLORS_FILE` env var in `.zshrc`

### B - CSS Import
- **waybar**: `@import url("colors.css")`; the repo's `colors.css` is a
  symlink to `~/.config/themes/current/waybar-colors.css`

### C - Full Template
The whole config is generated; the stow package ships a symlink.
- **mako, fuzzel, yazi, fastfetch, starship, lazygit**
- starship and lazygit moved here 2026-08-17 (the old in-place marker
  rewriting - Pattern D - is retired). Structural edits to those two apps
  now happen in `templates/starship.toml.tera` /
  `templates/lazygit-config.yml.tera`, applied with `theme-apply`.
- **hyprpaper** is a special case: `hypr/.config/hypr/hyprpaper.conf` is a
  committed symlink to `~/.config/themes/current/hyprpaper.conf`, but that
  file is written by `theme-set`'s wallpaper step (not a matugen template),
  because palettes without a `wallpaper` key must leave the previous
  wallpaper in place.

### E - Per-Palette Metadata
- **neovim**: `apps/<palette>/neovim.lua` is copied by theme-set to
  `~/.config/themes/current/nvim-colorscheme.lua`. The committed
  `nvim/lua/plugins/colorscheme.lua` is a stub that `dofile`s it with a
  catppuccin fallback, so palette switches never touch the repo.

## Commands

### theme-set \<palette\>
1. Copies `palettes/<name>.toml` to `colors.toml` (gitignored)
2. Runs `theme-apply` (render + atomic swap; aborts untouched on error)
3. Copies `apps/<name>/neovim.lua` if present
4. Reloads: SIGUSR2 to ghostty and waybar, `makoctl reload`, `hyprctl reload`
5. Wallpaper, if the palette defines one: instant per-monitor `hyprctl
   hyprpaper wallpaper` IPC, and regenerates
   `~/.config/themes/current/hyprpaper.conf` (single empty-monitor block =
   applies to every output) for the next login

### theme-apply
Render-only path (steps 1-2 above); auto-defaults `colors.toml` to
catppuccin-mocha when missing. Writes a wallpaperless `hyprpaper.conf` stub
if none exists so the stowed symlink never dangles.

### theme-set (no args)
Lists palettes, marking the active one (byte-diff against `colors.toml`).

### theme-set --neovim \<palette\>
Updates only the neovim colorscheme; prints a how-to and exits 1 when the
palette has no `apps/<palette>/neovim.lua`.

### theme-wallpaper [--save] [\<path\>]
Switch the wallpaper without switching palettes. No path: fuzzel picker over
`~/pics/wallpapers/` (bound to SUPER+W). Applies via hyprctl IPC and persists
to the generated hyprpaper.conf. The quick switch survives logins and lasts
until the next `theme-set` of a wallpaper-bearing palette. `--save`
additionally writes the wallpaper into the active palette's TOML - the one
deliberate git-tracked edit in the system; commit it when ready. theme-set
delegates its wallpaper step to this script.

### theme-import [theme-name]
Imports a ghostty theme into a palette TOML (unchanged from the old engine;
`--list`, `--apply`, `--force`, fzf browser with no args).

## Directory Structure

```
themes/
  colors.toml              # Active palette (gitignored, written by theme-set)
  matugen.toml             # matugen config: template list + staging outputs
  palettes/                # 9 palettes
  templates/               # 12 *.tera templates (Pattern A/B/C)
  apps/                    # Pattern E metadata (catppuccin-mocha, tokyo-night)
  bin/
    theme-set
    theme-apply
    theme-wallpaper        # wallpaper picker/switcher (SUPER+W)
    palette-to-json        # TOML -> matugen JSON + derived colors; --wallpaper
    theme-import
  SPEC.md
```

Runtime output (not in git): `~/.config/themes/current/` plus the transient
`~/.config/themes/.staging/`. The file `current/hyprland.conf` is an orphan
kept for the legacy `hypr/.config/hypr/hyprland.conf` rollback config; delete
both together when the Hyprland Lua cutover is finalized.

## Adding a New Palette

1. `palettes/<name>.toml` with all 22 keys (or `theme-import` a ghostty theme)
2. Optional `wallpaper = "~/..."` line
3. Optional `apps/<name>/neovim.lua` (copy TEMPLATE-neovim.lua)
4. `theme-set <name>`

## Adding a New App

1. Create `templates/<app>.<ext>.tera` (full config for Pattern C, fragment
   for Pattern A/B)
2. Add a `[templates.<app>]` stanza to `matugen.toml`: repo-relative
   `input_path`, `output_path = "~/.config/themes/.staging/<final-name>"`
3. Wire the app: source/import line (A/B) or replace its stow-package config
   with a relative symlink into `~/.config/themes/current/` (C)
4. If the app needs a reload signal, add it to theme-set's reload block

## Reload Behavior

| App | Auto-reloads? | theme-set action |
|-----|--------------|------------------|
| Ghostty | No | SIGUSR2 |
| Hyprland | No | hyprctl reload (re-reads hypr-colors.lua) |
| Hyprlock | Yes (per-invocation) | - |
| Btop | No | Restart manually |
| Waybar | No (inotify misses imports) | SIGUSR2 |
| Mako | No | makoctl reload |
| Fuzzel | Yes (per-invocation) | - |
| Yazi | No | Restart manually |
| Fastfetch | Yes (per-invocation) | - |
| Starship | Yes (per-prompt) | - |
| Lazygit | No | Restart manually |
| Hyprpaper | No | hyprctl IPC (instant) |
| Neovim | No | Restart manually |
| Newt/nmtui | Yes (per-invocation) | - |

## Bootstrap (fresh clone)

1. Install matugen (`paru -S matugen`; python3 is in base)
2. `stow` all packages - the Pattern C symlinks dangle harmlessly until step 3
3. `theme-set <palette>` once - renders everything, seeds hyprpaper.conf
   (stub if the palette has no wallpaper), copies the nvim spec

Before step 3: hyprland/hyprlock tolerate the missing files (`noerror` guard
and the Lua fallback table), nvim falls back to catppuccin via the stub, newt
ignores a missing `NEWT_COLORS_FILE`.

## Design Decisions

- **matugen over the old bash+sed engine** (2026-08-17): maintained Tera
  engine instead of ~500 lines of custom sed; all-or-nothing rendering plus
  the staging swap makes failed renders harmless. The cutover was gated on a
  parity harness proving byte-identical output for all 9 palettes x 12 files.
- **Derived colors precomputed in palette-to-json, not matugen filters**: the
  vivid/gradient math stays bit-identical to the original engine and
  templates stay pure interpolation.
- **Per-file atomic swap over a directory swap** (idea borrowed from
  Omarchy): `current/` also holds files matugen does not render
  (hyprpaper.conf, nvim-colorscheme.lua, palette.json) that must survive.
- **theme.toml over yazi flavors**: flavors need 6 boilerplate files in a
  hardcoded path; generating `theme.toml` is one file and full control.
- **hyprlang noerror over exec-once bootstrap**: `source` errors on missing
  files and `exec-once` runs after parsing, so a bootstrap script cannot win
  that race.

## Future Enhancements

- **TUI palette previewer** - browse palettes with live preview
- **GTK/Qt theme** - dark/light mode + accent via gsettings
- **Cursor theme** - per palette
- **Palette from wallpaper** (`wallpaper-theme <image>`, planned 2026-08-17):
  build it as a palette PRODUCER, symmetric with theme-import - extract
  colors, write `palettes/wallpaper-<name>.toml` (22 keys + wallpaper line),
  then `theme-set` it; the engine stays untouched. Extraction: matugen's
  `image` mode with `--json --dry-run` supplies the Material You scheme for
  accent/background/foreground; a small python shim (colorsys) synthesizes
  the ANSI color0-15 ramp from standard hues tinted with the wallpaper's
  saturation/lightness, since M3 has no terminal ramp and legibility (diffs,
  syntax, taskwarrior) depends on distinguishable red/green/yellow/blue.
  Fallback extractor if ramp quality disappoints: wallust (AUR). Generated
  palettes get no neovim spec (previous colorscheme persists) and live under
  the `wallpaper-` prefix so curated palettes stay first-class.

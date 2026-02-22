# Theme System Specification

A bash+sed template engine that provides centralized color management for all desktop applications. Single source of truth for colors, applied via `theme-set` and `theme-apply`.

## colors.toml Format

22 keys defining the full color palette:

```toml
accent = "#89b4fa"
cursor = "#f5e0dc"
foreground = "#cdd6f4"
background = "#1e1e2e"
selection_foreground = "#1e1e2e"
selection_background = "#f5e0dc"
color0 = "#45475a"     # through color15
```

## Template Variable Syntax

Three formats available for each color key:

| Syntax | Output | Example |
|--------|--------|---------|
| `{key}` | `#hex` | `{accent}` -> `#89b4fa` |
| `{key.strip}` | `hex` (no #) | `{accent.strip}` -> `89b4fa` |
| `{key.rgb}` | `r, g, b` decimal | `{accent.rgb}` -> `137, 180, 250` |

Named aliases are derived automatically from numbered colors:
- `red`=color1, `green`=color2, `yellow`=color3, `blue`=color4
- `magenta`=color5, `cyan`=color6, `white`=color7
- `bright_red`=color9, `bright_green`=color10, `bright_yellow`=color11
- `bright_blue`=color12, `bright_magenta`=color13, `bright_cyan`=color14

## Consumption Patterns

### A - Import Fragment
Config file adds one `source`/`config-file` line pointing to generated output.
- **Apps**: ghostty, hyprland, hyprlock, btop
- **Templates**: `templates/*.tpl` -> `~/.config/themes/current/*`
- **Hyprland/Hyprlock note**: wrap source lines with `# hyprlang noerror true` / `# hyprlang noerror false` so a missing file (before first `theme-set`) doesn't produce a config error. This is a standard hyprlang feature used by major dotfile repos.

### B - CSS Import
CSS file uses `@import` for color definitions; structural CSS stays in stow package.
- **Apps**: waybar
- **Template**: `templates/waybar-colors.css.tpl` -> `~/.config/themes/current/waybar-colors.css`

### C - Full Template
Entire config is a template. Stow package has symlink pointing to generated output.
- **Apps**: mako, hyprtoolkit, fuzzel, yazi
- **Templates**: `templates/*.tpl` -> `~/.config/themes/current/*`
- **Yazi note**: we generate a full `theme.toml` rather than using yazi's "flavor" system. Flavors are distribution packages requiring 6 boilerplate files in a hardcoded path (`~/.config/yazi/flavors/`). Generating `theme.toml` directly from our palette is simpler, gives full control, and is the same approach that catppuccin/yazi uses internally to build its flavor files.

### D - In-Place Markers
Config stays in stow package. Lines between `### THEME-START ###` and `### THEME-END ###` markers are replaced in-place by theme-apply.
- **Apps**: starship, lazygit
- **Marker templates**: `markers/*.tpl`

### E - Per-Palette Metadata
Each palette ships app-specific config (not color templates). Copied to target location by theme-set.
- **Apps**: neovim
- **Files**: `apps/<palette>/neovim.lua` -> `~/.config/nvim/lua/plugins/colorscheme.lua`

## Commands

### theme-set \<palette\>
Switch the active palette and apply it:
1. Copies `palettes/<name>.toml` to `colors.toml`
2. Runs `theme-apply`
3. Copies neovim metadata from `apps/<name>/`
4. Sends SIGUSR2 to ghostty, reloads mako

### theme-apply
Process all templates using the current `colors.toml`:
1. Parses colors.toml into variables
2. Processes `templates/*.tpl` -> `~/.config/themes/current/`
3. Processes `markers/*.tpl` -> replaces marker sections in target configs

### theme-set (no args)
Lists available palettes, marking the active one.

## Directory Structure

```
themes/
  colors.toml              # Active palette (written by theme-set)
  palettes/                # Available palettes
    catppuccin-mocha.toml
    tokyo-night.toml
  templates/               # Pattern A/B/C templates
    ghostty.conf.tpl
    hyprland.conf.tpl
    hyprlock.conf.tpl
    btop.theme.tpl
    waybar-colors.css.tpl
    mako.conf.tpl
    hyprtoolkit.conf.tpl
    fuzzel.ini.tpl
    yazi-theme.toml.tpl
  markers/                 # Pattern D templates
    starship-palette.tpl
    lazygit-theme.tpl
  apps/                    # Pattern E metadata
    catppuccin-mocha/
      neovim.lua
    tokyo-night/
      neovim.lua
  bin/
    theme-set
    theme-apply
  SPEC.md
```

Runtime output (not in git): `~/.config/themes/current/`

## Adding a New Palette

1. Create `palettes/<name>.toml` with all 22 color keys
2. Optionally add `apps/<name>/neovim.lua` with a LazyVim colorscheme spec
3. Test: `theme-set <name>`

## Adding a New App

Determine which pattern fits:

**Pattern A** (app supports sourcing/importing external file):
1. Create `templates/<app>.conf.tpl` with `{variable}` placeholders
2. Add a `source`/`config-file`/`include` line to the app's main config pointing to `~/.config/themes/current/<app>.conf`

**Pattern B** (CSS with @import):
1. Create `templates/<app>-colors.css.tpl` with color definitions
2. Add `@import` to the app's main CSS

**Pattern C** (entire config is theme-dependent):
1. Create `templates/<app>.conf.tpl` with the full config
2. Replace the stow package's config file with a symlink to `~/.config/themes/current/<app>.conf`

**Pattern D** (config has both theme and non-theme parts):
1. Create `markers/<app>-theme.tpl` with just the theme section
2. Add `# ### THEME-START ###` and `# ### THEME-END ###` markers in the app's config
3. Add a case in `theme-apply` to map the marker file to the target config path

**Pattern E** (per-palette metadata, not templated):
1. Add files under `apps/<palette>/` for each palette
2. Add copy logic in `theme-set`

## Reload Behavior

| App | Auto-reloads? | theme-set action |
|-----|--------------|------------------|
| Ghostty | No | SIGUSR2 |
| Hyprland | Yes (inotify) | - |
| Hyprlock | Yes (per-invocation) | - |
| Btop | No | Restart manually |
| Waybar | No (inotify only watches main CSS, not imports) | SIGUSR2 |
| Mako | No | makoctl reload |
| Hyprtoolkit | Yes (inotify) | - |
| Fuzzel | Yes (per-invocation) | - |
| Yazi | No | Restart manually |
| Starship | Yes (per-invocation) | - |
| Lazygit | No | Restart manually |
| Neovim | No | Restart manually |

## Bootstrap

On a fresh clone, run `theme-set catppuccin-mocha` (or any palette) once after stowing packages. Hyprland and hyprlock configs use `# hyprlang noerror true` to gracefully handle the case where generated files don't exist yet, so there's no hard failure on first boot.

`theme-apply` also auto-defaults to catppuccin-mocha if `colors.toml` doesn't exist, so running `theme-apply` alone on a fresh setup will work.

## Design Decisions

### Why theme.toml over yazi flavors

Yazi "flavors" are pre-packaged distributable themes stored in `~/.config/yazi/flavors/<name>.yazi/`. They require 6 files (flavor.toml, tmtheme.xml, README.md, preview.png, LICENSE, LICENSE-tmtheme) and the path is hardcoded - no custom paths accepted. Yazi's three-layer merge (preset -> flavor -> theme.toml) adds complexity.

Generating a full `theme.toml` is simpler: one file, one symlink, full control over every property, no boilerplate. This is the same approach catppuccin/yazi uses to build its own flavor files from Tera templates.

### Why hyprlang noerror over exec-once bootstrap

Hyprland's `source` directive errors when the target file doesn't exist, and `exec-once` runs after config parsing - so a bootstrap script can't create the files in time for the initial load. The `# hyprlang noerror true` directive is a first-class hyprlang feature that suppresses parse errors for the wrapped lines. This is the standard approach used by prasanthrangan/hyprdots.

## Future Enhancements

- **TUI palette previewer** - interactive terminal UI for browsing palettes, previewing colors.toml files, and fine-tuning individual color values before applying
- **Wallpaper support** - optional `wallpaper = "/path/to/image.jpg"` field in palette files; theme-set updates hyprpaper.conf
- **GTK/Qt theme** - set dark/light mode + accent color via gsettings
- **Cursor theme** - set cursor theme per palette
- **Palette from wallpaper** - extract dominant colors from an image into a colors.toml
- **Additional palettes** - gruvbox, rose-pine, nord, kanagawa, everforest

pragma Singleton

// Colors and fonts shared by all components. Colors come from the theme
// engine (~/.config/themes/current/quickshell-colors.json) and update live
// when theme-set rewrites the file. The defaults apply until the file exists.
// Derived roles (glass, outline, dim, ...) are computed here from the
// palette, with a fallback to the foreground where contrast is too low.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    readonly property color background: colors.background
    readonly property color foreground: colors.foreground
    readonly property color accent: colors.accent
    readonly property color red: colors.red
    readonly property color yellow: colors.yellow
    readonly property color green: colors.green
    readonly property color blue: colors.blue
    readonly property color magenta: colors.magenta
    readonly property color cyan: colors.cyan
    readonly property color brightBlack: colors.brightBlack
    readonly property color brightGreen: colors.brightGreen
    readonly property color brightCyan: colors.brightCyan

    // Outlines: 20% foreground over the background.
    readonly property color outline: Qt.tint(background, Qt.alpha(foreground, 0.20))
    // Frosted glass: the fill of the bar panels, the hub and buttons in
    // popups. Hyprland blurs what is behind it.
    readonly property color glass: Qt.alpha(foreground, 0.18)
    // Secondary text and inactive items.
    readonly property color dim: Qt.alpha(foreground, 0.6)
    // Week numbers, days outside the month.
    readonly property color faint: Qt.alpha(foreground, 0.4)
    // Unlit meter segments.
    readonly property color off: Qt.alpha(foreground, 0.14)
    // Thin dividers.
    readonly property color divider: Qt.alpha(foreground, 0.2)
    // Tint over a control under the pointer.
    readonly property color hover: Qt.alpha(foreground, 0.10)
    // Translucent fill of the bar and its popups. Hyprland only blurs behind
    // pixels with at least 30% opacity (ignore_alpha in look.lua).
    readonly property color barFill: Qt.alpha(background, 0.85)
    // Edge lines: a raised panel has a light top edge and a dark bottom edge,
    // a sunken one a deep top edge and a faint light bottom edge.
    readonly property color edgeLight: Qt.alpha(foreground, 0.10)
    readonly property color edgeDark: Qt.rgba(0, 0, 0, 0.35)
    readonly property color edgeDeep: Qt.rgba(0, 0, 0, 0.5)
    readonly property color edgeFaint: Qt.alpha(foreground, 0.08)
    // State colors for text, icons and small fills: the palette's green,
    // yellow, red and cyan, each replaced by the foreground where it is too
    // close to the background to read.
    readonly property color good: readable(green)
    readonly property color warn: readable(yellow)
    readonly property color bad: readable(red)
    readonly property color info: readable(cyan)
    // Fill for the current item: the accent, or the foreground when the
    // accent is too close to the background to see.
    readonly property color accentFill: contrast(accent, background) >= 3 ? accent : foreground
    // Text on top of accentFill.
    readonly property color onAccent: textOn(accentFill)

    // The color, or the foreground when the color has a contrast below 3
    // against the background.
    function readable(c) {
        return contrast(c, background) >= 3 ? c : foreground;
    }

    // A palette color for a label: readable, and never the accent, which is
    // kept for the clock and other current items; dim when it would match.
    function labelHue(c) {
        const a = accentFill;
        const close = Math.abs(c.r - a.r) + Math.abs(c.g - a.g) + Math.abs(c.b - a.b) < 0.06;
        return close ? dim : readable(c);
    }

    // Text on top of a fill: the background or the foreground, whichever
    // stands out more.
    function textOn(fill) {
        return contrast(background, fill) >= contrast(foreground, fill) ? background : foreground;
    }

    // WCAG relative luminance and contrast ratio.
    function luminance(c) {
        const channel = v => v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
        return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
    }

    function contrast(a, b) {
        const la = luminance(a);
        const lb = luminance(b);
        return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/themes/current/quickshell-colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: colors

            property string background: "#1a1b26"
            property string foreground: "#c0caf5"
            property string accent: "#7aa2f7"
            property string red: "#f7768e"
            property string yellow: "#e0af68"
            property string green: "#9ece6a"
            property string blue: "#7aa2f7"
            property string magenta: "#bb9af7"
            property string cyan: "#7dcfff"
            property string brightBlack: "#414868"
            property string brightGreen: "#9ece6a"
            property string brightCyan: "#7dcfff"
        }
    }
}

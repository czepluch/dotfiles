pragma Singleton

// Colors and fonts shared by all components. Colors come from the theme
// engine (~/.config/themes/current/quickshell-colors.json) and update live
// when theme-set rewrites the file. The defaults apply until the file exists.
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
        }
    }
}

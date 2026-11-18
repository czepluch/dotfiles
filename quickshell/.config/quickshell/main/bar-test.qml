//@ pragma NativeTextRendering
//@ pragma IconTheme Adwaita
// Shows the bar along the bottom of the widest screen only, next to a
// running Waybar.
// Run with: qs -p ~/.config/quickshell/main/bar-test.qml
import Quickshell
import qs.bar

ShellRoot {
    Bar {
        bottom: true
        screens: [Array.from(Quickshell.screens).reduce((a, b) => b.width > a.width ? b : a)]
    }
}

//@ pragma NativeTextRendering
//@ pragma IconTheme Adwaita
// Shows the bar along the bottom of every screen, next to a running Waybar.
// Run with: qs -p ~/.config/quickshell/main/bar-test.qml
import Quickshell
import qs.bar

ShellRoot {
    Bar {
        bottom: true
    }
}

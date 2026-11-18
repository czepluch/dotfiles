//@ pragma NativeTextRendering
//@ pragma IconTheme Adwaita
// Shows a second bar along the bottom of every screen, for trying changes
// next to the shell's own bar.
// Run with: qs -p ~/.config/quickshell/main/bar-test.qml
import Quickshell
import qs.bar

ShellRoot {
    Bar {
        bottom: true
    }
}

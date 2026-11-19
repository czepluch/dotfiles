//@ pragma NativeTextRendering
//@ pragma IconTheme Adwaita
// Quickshell entry point: the bar on every screen, which also shows the
// notifications, and the lock screen.
// Run with: qs -c main
import Quickshell
import qs.bar
import qs.lock

ShellRoot {
    Bar {}
    Lock {}
}

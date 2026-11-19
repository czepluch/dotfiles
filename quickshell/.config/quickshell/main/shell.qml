//@ pragma NativeTextRendering
//@ pragma IconTheme Adwaita
// Quickshell entry point: the bar on every screen, which also shows the
// notifications, the launcher (also the session menu and the clipboard
// history) and the lock screen.
// Run with: qs -c main
import Quickshell
import qs.bar
import qs.launcher
import qs.lock

ShellRoot {
    Bar {}
    LauncherWindow {}
    Lock {}
}

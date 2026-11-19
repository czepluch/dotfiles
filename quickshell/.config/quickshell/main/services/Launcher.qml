pragma Singleton

// Which picker is open: the app launcher ("apps"), the session menu
// ("session"), the clipboard history ("clipboard"), or the palette or
// wallpaper picker ("palettes", "wallpapers"). It opens centered on the
// screen with Hyprland's focused monitor (see launcher/LauncherWindow).
// close() closes it after a choice; cancel() closes it without one (Escape,
// a click outside, the same toggle again), and the theme pickers then go
// back to what was in use before.
//
// qs -c main ipc call launcher toggle <apps|session|clipboard|palettes|wallpapers>
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    // "" while closed.
    property string mode: ""
    property ShellScreen screen: null

    signal cancelled(string mode)

    function open(newMode) {
        if (!["apps", "session", "clipboard", "palettes", "wallpapers"].includes(newMode))
            return;
        const screens = Array.from(Quickshell.screens);
        screen = screens.find(s => Hyprland.monitorFor(s) === Hyprland.focusedMonitor) ?? screens[0] ?? null;
        mode = newMode;
    }

    function close() {
        mode = "";
    }

    function cancel() {
        const was = mode;
        mode = "";
        if (was !== "")
            cancelled(was);
    }

    function toggle(newMode) {
        if (mode === newMode)
            cancel();
        else
            open(newMode);
    }

    IpcHandler {
        target: "launcher"

        function toggle(mode: string): void {
            root.toggle(mode);
        }
    }
}

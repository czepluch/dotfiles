pragma Singleton

// Which picker is open: the app launcher ("apps"), the session menu
// ("session") or the clipboard history ("clipboard"). It opens centered on
// the screen with Hyprland's focused monitor (see launcher/LauncherWindow).
//
// qs -c main ipc call launcher toggle <apps|session|clipboard>
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    // "" while closed.
    property string mode: ""
    property ShellScreen screen: null

    function open(newMode) {
        if (!["apps", "session", "clipboard"].includes(newMode))
            return;
        const screens = Array.from(Quickshell.screens);
        screen = screens.find(s => Hyprland.monitorFor(s) === Hyprland.focusedMonitor) ?? screens[0] ?? null;
        mode = newMode;
    }

    function close() {
        mode = "";
    }

    function toggle(newMode) {
        if (mode === newMode)
            close();
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

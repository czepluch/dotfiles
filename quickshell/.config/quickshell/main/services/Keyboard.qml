pragma Singleton

// Layout and Caps Lock state of the main keyboard, from Hyprland.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    // Full layout name from Hyprland, for example "English (intl., with AltGr dead keys)".
    property string layoutName: ""
    // The layout name without its variant, for example "English".
    readonly property string shortName: layoutName.split(" (")[0]
    // Short label: EN, DA, or the first two letters of other layouts.
    readonly property string layout: {
        if (layoutName.startsWith("English"))
            return "EN";
        if (layoutName.startsWith("Danish"))
            return "DA";
        return layoutName.slice(0, 2).toUpperCase();
    }
    property bool capsLock: false

    // Starting the query while one runs queues a single rerun, so the last
    // of several quick events is never lost.
    function refresh() {
        devices.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: devices

        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const keyboards = JSON.parse(text).keyboards;
                    const main = keyboards.find(k => k.main) ?? keyboards[0];
                    if (main)
                        root.layoutName = main.active_keymap;
                    root.capsLock = keyboards.some(k => k.capsLock);
                } catch (e) {
                    console.warn("Reading keyboards failed:", e);
                }
            }
        }
    }

    // Hyprland reports layout switches as "activelayout>>keyboard,layout".
    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activelayout")
                root.refresh();
        }
    }
}

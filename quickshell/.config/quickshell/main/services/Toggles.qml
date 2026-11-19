pragma Singleton

// State and switching of the control panel toggle that lives outside
// Quickshell: night light (sunsetr running). It is read every 30 s while
// the session is active, when it becomes active, and after each switch.
// Do-not-disturb lives in Notifications, keep awake in Session, Bluetooth
// and microphone mute in their services.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool nightLight: false

    // Starting a query while it runs queues a single rerun.
    function refresh() {
        nightLightQuery.running = true;
    }

    function toggleNightLight() {
        nightLight = !nightLight;
        nightLightAction.command = nightLight ? ["sunsetr", "--background"] : ["sunsetr", "stop"];
        nightLightAction.running = true;
    }

    function warnOnFailure(name, exitCode) {
        if (exitCode !== 0)
            console.warn(name, "failed with exit code", exitCode);
    }

    Component.onCompleted: refresh()

    Connections {
        target: Session

        function onActiveChanged() {
            if (Session.active)
                root.refresh();
        }
    }

    Timer {
        interval: 30000
        running: Session.active
        repeat: true
        onTriggered: root.refresh()
    }

    // sunsetr --background returns before the new instance is up, so the
    // state is read again a moment later.
    Process {
        id: nightLightAction

        onExited: exitCode => {
            root.warnOnFailure("Night light", exitCode);
            nightLightRecheck.restart();
        }
    }

    Timer {
        id: nightLightRecheck

        interval: 1000
        onTriggered: nightLightQuery.running = true
    }

    Process {
        id: nightLightQuery

        command: ["pgrep", "-x", "sunsetr"]
        onExited: exitCode => root.nightLight = exitCode === 0
    }
}

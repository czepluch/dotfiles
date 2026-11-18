pragma Singleton

// State and switching of the control panel toggles that live outside
// Quickshell: do-not-disturb (a mako mode) and night light (sunsetr
// running). Both are read every 30 s while the session is active, when it
// becomes active, and after each switch. Keep awake lives in Session,
// Bluetooth and microphone mute in their services.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool dnd: false
    property bool nightLight: false

    // Starting a query while it runs queues a single rerun.
    function refresh() {
        dndQuery.running = true;
        nightLightQuery.running = true;
    }

    function toggleDnd() {
        dnd = !dnd;
        dndAction.running = true;
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

    Process {
        id: dndAction

        command: ["makoctl", "mode", "-t", "do-not-disturb"]
        onExited: exitCode => {
            root.warnOnFailure("Do not disturb", exitCode);
            dndQuery.running = true;
        }
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
        id: dndQuery

        command: ["makoctl", "mode"]
        stdout: StdioCollector {
            onStreamFinished: root.dnd = text.split("\n").includes("do-not-disturb")
        }
    }

    Process {
        id: nightLightQuery

        command: ["pgrep", "-x", "sunsetr"]
        onExited: exitCode => root.nightLight = exitCode === 0
    }
}

pragma Singleton

// Short messages the hub shows in place of the time: a volume change or a
// keyboard layout switch for 2 s, and a countdown over the last 10 s before
// the idle lock. The countdown uses the same times as hypridle's warning
// (170 s) and lock (180 s) listeners in hypr/.config/hypr/hypridle.conf and
// ends on any input.
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root

    // "" for none, "volume", "layout" or "lock".
    property string message: ""
    readonly property int lockWarning: 170
    readonly property int lockAfter: 180
    // Seconds left until the lock while the countdown runs.
    property int lockRemaining: 0
    // Values that arrive in the first moments after start are the initial
    // state, not something the user did.
    property bool armed: false

    function show(kind) {
        if (!armed || message === "lock")
            return;
        message = kind;
        hold.restart();
    }

    Timer {
        id: hold

        interval: 2000
        onTriggered: {
            if (root.message !== "lock")
                root.message = "";
        }
    }

    Timer {
        interval: 1500
        running: true
        onTriggered: root.armed = true
    }

    Connections {
        target: Audio

        function onVolumeChanged() {
            root.show("volume");
        }

        function onMutedChanged() {
            root.show("volume");
        }
    }

    Connections {
        target: Keyboard

        function onLayoutNameChanged() {
            root.show("layout");
        }
    }

    IdleMonitor {
        timeout: root.lockWarning
        respectInhibitors: true
        onIsIdleChanged: {
            if (isIdle) {
                root.lockRemaining = root.lockAfter - root.lockWarning;
                root.message = "lock";
                countdown.restart();
            } else if (root.message === "lock") {
                countdown.stop();
                root.message = "";
            }
        }
    }

    Timer {
        id: countdown

        interval: 1000
        repeat: true
        onTriggered: {
            if (root.lockRemaining > 0)
                root.lockRemaining--;
            else
                stop();
        }
    }
}

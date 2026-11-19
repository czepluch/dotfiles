pragma Singleton

// Short messages shown under the clock: a change of volume or brightness,
// a keyboard layout switch or do-not-disturb switched on or off for 2 s,
// and a countdown over the last 10 s before the idle lock. The countdown
// uses the same times as hypridle's warning (170 s) and lock (180 s)
// listeners in hypr/.config/hypr/hypridle.conf and ends on any input.
// hypridle's warning dims the screen and restores it when the countdown
// ends; that restore shows no message.
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root

    // "" for none, "volume", "brightness", "layout", "dnd" or "lock".
    property string message: ""
    readonly property int lockWarning: 170
    readonly property int lockAfter: 180
    // Seconds left until the lock while the countdown runs.
    property int lockRemaining: 0
    // Values that arrive in the first moments after start are the initial
    // state, not something the user did.
    property bool armed: false

    function show(kind) {
        if (!armed || message === "lock" || (kind === "brightness" && restoring.running))
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

    Connections {
        target: Notifications

        function onDndChanged() {
            root.show("dnd");
        }
    }

    Connections {
        target: Brightness

        function onCurrentChanged() {
            root.show("brightness");
        }
    }

    // Runs for a moment after the countdown ends, while the brightness is
    // restored.
    Timer {
        id: restoring

        interval: 2000
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
                restoring.restart();
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

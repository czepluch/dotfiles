pragma Singleton

// Laptop screen backlight. Read from /sys at start and whenever the file
// changes, set through brightnessctl. While a set is running, only the
// newest requested value is kept and applied next, and the value is read
// back only after the last set.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string device: ""
    readonly property bool available: device !== ""
    property real max: 0
    property real current: 0
    readonly property real value: max > 0 ? current / max : 0
    // Percent waiting for the running set to finish, or -1.
    property int pendingPercent: -1

    function refresh() {
        if (available)
            brightnessFile.reload();
    }

    // Sets the brightness from 0 to 1, never fully off.
    function set(v) {
        const percent = Math.max(1, Math.round(v * 100));
        current = max * percent / 100;
        if (setter.running)
            pendingPercent = percent;
        else
            run(percent);
    }

    function run(percent) {
        setter.command = ["brightnessctl", "-q", "set", percent + "%"];
        setter.running = true;
    }

    Process {
        running: true
        command: ["sh", "-c", "ls /sys/class/backlight | head -n 1"]
        stdout: StdioCollector {
            onStreamFinished: root.device = text.trim()
        }
    }

    FileView {
        path: root.available ? "/sys/class/backlight/" + root.device + "/max_brightness" : ""
        onLoaded: root.max = Number(text())
    }

    FileView {
        id: brightnessFile

        path: root.available ? "/sys/class/backlight/" + root.device + "/brightness" : ""
        watchChanges: true
        onFileChanged: {
            if (!setter.running)
                reload();
        }
        onLoaded: root.current = Number(text())
    }

    Process {
        id: setter

        onExited: {
            if (root.pendingPercent >= 0) {
                const percent = root.pendingPercent;
                root.pendingPercent = -1;
                Qt.callLater(() => root.run(percent));
            } else {
                root.refresh();
            }
        }
    }
}

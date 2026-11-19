pragma Singleton

// Whether anyone can see the shell, keep awake, and resume detection.
// Services pause their timers while the session is locked or idle.
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root

    // Set by the lock screen (lock/Lock.qml) while it is up.
    property bool locked: false
    readonly property bool idle: idleMonitor.isIdle
    readonly property bool active: !locked && !idle
    // Blocks the idle lock and suspend while true (each bar holds an idle inhibitor).
    property bool keepAwake: false
    // Time of the last check below, in ms since the epoch.
    property real lastCheck: Date.now()

    // Emitted within 10 s after the machine wakes from suspend. Timers run on
    // a clock that stops during suspend, so clocks use this to catch up.
    signal resumed()

    // Idle after 2 minutes without input. Video players and other idle
    // inhibitors keep the session active.
    IdleMonitor {
        id: idleMonitor

        timeout: 120
        respectInhibitors: true
    }

    // A wall-clock jump between two checks means the machine was suspended.
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            const now = Date.now();
            if (now - root.lastCheck > 30000)
                root.resumed();
            root.lastCheck = now;
        }
    }
}

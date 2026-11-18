// Shows the lock screen UI in a normal window without locking the session.
// A correct password or closing the window ends the test; the raised blur
// is restored first.
// Run with: qs -p ~/.config/quickshell/main/lock-test.qml
import QtQuick
import Quickshell
import qs.lock

ShellRoot {
    id: root

    function finish() {
        lockContext.active = false;
        Qt.callLater(Qt.quit);
    }

    LockContext {
        id: lockContext

        active: true
        onUnlocked: root.finish()
    }

    FloatingWindow {
        implicitWidth: 1280
        implicitHeight: 800
        color: "transparent"

        LockSurface {
            anchors.fill: parent
            context: lockContext
        }
    }

    Connections {
        target: Quickshell

        function onLastWindowClosed() {
            root.finish();
        }
    }
}

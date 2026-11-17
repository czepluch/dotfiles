// Shows the lock screen UI in a normal window without locking the session.
// A correct password closes the window.
// Run with: qs -p ~/.config/quickshell/main/test.qml
import QtQuick
import Quickshell
import qs.lock

ShellRoot {
    LockContext {
        id: lockContext

        active: true
        onUnlocked: Qt.quit()
        Component.onCompleted: refreshKeyboard()
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
            Qt.quit();
        }
    }
}

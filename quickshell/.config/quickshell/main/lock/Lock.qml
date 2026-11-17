// Session lock. Shows LockSurface on every monitor while locked.
// Lock from a shell with: qs -c main ipc call lock lock
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    function lock() {
        if (sessionLock.locked)
            return;
        lockContext.reset();
        lockContext.refreshKeyboard();
        sessionLock.locked = true;
    }

    LockContext {
        id: lockContext

        // Follows `secure` (the compositor has confirmed the lock) because
        // Quickshell 0.3.2 does not notify `locked` changes on unlock.
        active: sessionLock.secure
        onUnlocked: sessionLock.locked = false
    }

    WlSessionLock {
        id: sessionLock

        locked: false

        WlSessionLockSurface {
            color: "transparent"

            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.lock();
        }

        function isLocked(): bool {
            return sessionLock.locked;
        }
    }
}

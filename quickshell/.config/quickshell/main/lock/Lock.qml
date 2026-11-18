// Session lock. Shows LockSurface on every monitor while locked, and tells
// Session while the lock is up.
// Lock from a shell with: qs -c main ipc call lock lock
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services

Scope {
    id: root

    function lock() {
        if (sessionLock.locked)
            return;
        lockContext.reset();
        Keyboard.refresh();
        sessionLock.locked = true;
    }

    LockContext {
        id: lockContext

        // Follows `secure` (the compositor has confirmed the lock) because
        // Quickshell 0.3.2 does not notify `locked` changes on unlock.
        active: sessionLock.secure
        onUnlocked: sessionLock.locked = false
    }

    Binding {
        target: Session
        property: "locked"
        value: sessionLock.secure
    }

    WlSessionLock {
        id: sessionLock

        locked: false

        WlSessionLockSurface {
            id: lockSurface

            color: "transparent"

            LockSurface {
                anchors.fill: parent
                context: lockContext
                screen: lockSurface.screen
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

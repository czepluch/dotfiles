// State shared by the lock surfaces on every monitor: the typed password,
// the PAM conversation and the blur behind the lock. After a correct
// password, `unlocking` is set so the surfaces can play their closing
// animation, and `unlocked` follows once it has run.
import QtQuick
import Quickshell
import Quickshell.Services.Pam
import qs.components

Scope {
    id: root

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property string failureText: ""
    property string pamError: ""
    // True while the lock screen is showing; raises Hyprland's blur.
    property bool active: false
    // True from a correct password until the lock is released.
    property bool unlocking: false
    // True once the desktop behind the lock is blurred enough to show.
    readonly property bool blurReady: blur.raised

    signal unlocked()
    signal failed()

    function reset() {
        if (pam.active)
            pam.abort();
        currentText = "";
        showFailure = false;
        failureText = "";
        unlockInProgress = false;
        unlocking = false;
    }

    function tryUnlock() {
        if (currentText === "" || unlockInProgress)
            return;
        pamError = "";
        unlockInProgress = true;
        pam.start();
    }

    onCurrentTextChanged: showFailure = false

    LockBlur {
        id: blur

        active: root.active
    }

    // Uses the same PAM stack as hyprlock (auth include login).
    PamContext {
        id: pam

        configDirectory: "/etc/pam.d"
        config: "hyprlock"

        onPamMessage: {
            if (responseRequired)
                respond(root.currentText);
            else if (messageIsError)
                root.pamError = message;
        }

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.unlockInProgress = false;
                root.unlocking = true;
                release.restart();
                return;
            }
            const text = root.pamError !== "" ? root.pamError
                : result === PamResult.MaxTries ? "Too many attempts"
                : "Wrong password";
            root.currentText = "";
            root.failureText = text;
            root.showFailure = true;
            root.unlockInProgress = false;
            root.failed();
        }
    }

    // Lets the closing animation finish before the lock is released.
    Timer {
        id: release

        interval: Style.lockShrink
        onTriggered: root.unlocked()
    }
}

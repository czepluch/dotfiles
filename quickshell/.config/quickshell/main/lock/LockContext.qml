// State shared by the lock surfaces on every monitor: the typed password,
// the PAM conversation and the blur behind the lock.
import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property string failureText: ""
    property string pamError: ""
    // True while the lock screen is showing; raises Hyprland's blur.
    property bool active: false
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
                root.unlocked();
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
}

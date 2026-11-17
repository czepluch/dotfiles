// State shared by the lock surfaces on every monitor: the typed password,
// the PAM conversation, and the keyboard layout and Caps Lock state.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pam

Scope {
    id: root

    signal unlocked()
    signal failed()

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property string failureText: ""

    // Short layout label (EN/DA, as in waybar) and Caps Lock state.
    property string layout: ""
    property bool capsLock: false

    property string pamError: ""

    // True while the lock screen is showing. Polls the ETH price and raises
    // Hyprland's blur.
    property bool active: false
    // True once the desktop behind the lock is blurred enough to show.
    readonly property bool blurReady: blur.raised
    // ETH price in USD, or NaN until a fetch succeeds.
    property real ethPrice: NaN

    onCurrentTextChanged: showFailure = false

    function reset() {
        if (pam.active)
            pam.abort();
        currentText = "";
        showFailure = false;
        failureText = "";
        unlockInProgress = false;
        ethPrice = NaN;
    }

    function tryUnlock() {
        if (currentText === "" || unlockInProgress)
            return;
        pamError = "";
        unlockInProgress = true;
        pam.start();
    }

    function layoutLabel(keymap) {
        if (keymap.startsWith("English"))
            return "EN";
        if (keymap.startsWith("Danish"))
            return "DA";
        return keymap.slice(0, 2).toUpperCase();
    }

    function refreshKeyboard() {
        if (!devices.running)
            devices.running = true;
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

    // Reads the main keyboard's layout and Caps Lock state from Hyprland.
    Process {
        id: devices

        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const keyboards = JSON.parse(text).keyboards;
                const main = keyboards.find(k => k.main) ?? keyboards[0];
                if (main)
                    root.layout = root.layoutLabel(main.active_keymap);
                root.capsLock = keyboards.some(k => k.capsLock);
            }
        }
    }

    LockBlur {
        id: blur

        active: root.active
    }

    // Fetches the ETH price from the keyless CoinGecko API once a minute.
    Timer {
        interval: 60000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!ethFetch.running)
                ethFetch.running = true;
        }
    }

    Process {
        id: ethFetch

        command: ["curl", "-fsS", "--max-time", "10",
            "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const price = JSON.parse(text).ethereum.usd;
                    if (typeof price === "number")
                        root.ethPrice = price;
                } catch (e) {
                    console.warn("ETH price fetch failed:", e);
                }
            }
        }
    }

    // Hyprland reports layout switches as "activelayout>>keyboard,layout".
    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activelayout")
                root.refreshKeyboard();
        }
    }
}

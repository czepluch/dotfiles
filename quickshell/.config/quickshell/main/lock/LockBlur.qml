// Raises Hyprland's blur while active (the lock screen is up) and restores
// the user's values afterwards. Hyprland blurs the desktop behind the lock
// surface with the window blur settings. While the blur is raised, the
// user's values are kept in a state file, so a reload or a crash never loses
// them: an instance that starts while locked keeps the blur raised and an
// instance that starts unlocked restores the values from the file. A config
// reload while active puts the config's blur back, so the blur is raised
// again after each one.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Scope {
    id: root

    property bool active: false
    // True once Hyprland has applied the stronger blur.
    property bool raised: false

    readonly property int size: 10
    readonly property int passes: 6

    function apply(size, passes) {
        return ["hyprctl", "eval", "hl.config({decoration={blur={size=" + size + ",passes=" + passes + "}}})"];
    }

    // The user's values from the state file, or null when nothing is saved.
    function savedValues() {
        const text = state.text().trim();
        if (text === "")
            return null;
        try {
            return JSON.parse(text);
        } catch (e) {
            return null;
        }
    }

    function raise() {
        raised = false;
        if (savedValues() !== null)
            raiseBlur.running = true;
        else
            readBlur.running = true;
    }

    function restore() {
        const saved = savedValues();
        if (saved === null)
            return;
        Quickshell.execDetached(apply(saved.size, saved.passes));
        state.setText("");
    }

    onActiveChanged: {
        if (active) {
            raise();
        } else {
            raised = false;
            restore();
        }
    }

    Component.onCompleted: {
        if (active)
            raise();
        else
            restore();
    }

    FileView {
        id: state

        path: Quickshell.env("XDG_RUNTIME_DIR") + "/quickshell-lock-blur.json"
        blockLoading: true
        printErrors: false
    }

    // Reads the current blur values, one JSON object per line, saves them,
    // then raises the blur.
    Process {
        id: readBlur

        command: ["sh", "-c", "hyprctl -j getoption decoration:blur:size && hyprctl -j getoption decoration:blur:passes"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = text.trim().split("\n").map(line => JSON.parse(line));
                    state.setText(JSON.stringify({ size: lines[0].int, passes: lines[1].int }));
                } catch (e) {
                    console.warn("Reading blur settings failed:", e);
                    return;
                }
                if (root.active)
                    raiseBlur.running = true;
            }
        }
    }

    Process {
        id: raiseBlur

        command: root.apply(root.size, root.passes)
        onExited: exitCode => {
            if (!root.active)
                root.restore();
            else if (exitCode === 0)
                root.raised = true;
            else
                console.warn("Raising blur failed with exit code", exitCode);
        }
    }

    // Hyprland reports a config reload as "configreloaded>>".
    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "configreloaded" && root.active)
                root.raise();
        }
    }
}

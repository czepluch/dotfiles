// Raises Hyprland's blur while active and restores the previous values
// afterwards. Hyprland blurs the desktop behind the lock surface with the
// window blur settings.
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool active: false
    // True once Hyprland has applied the stronger blur.
    property bool raised: false

    readonly property int size: 5
    readonly property int passes: 4

    property var saved: null

    function apply(size, passes) {
        return ["hyprctl", "eval", "hl.config({decoration={blur={size=" + size + ",passes=" + passes + "}}})"];
    }

    function restore() {
        if (saved === null)
            return;
        Quickshell.execDetached(apply(saved.size, saved.passes));
    }

    onActiveChanged: {
        raised = false;
        if (active)
            save.running = true;
        else
            restore();
    }

    Component.onCompleted: {
        if (active)
            save.running = true;
    }

    Component.onDestruction: {
        if (active)
            restore();
    }

    // Reads the current blur values, one JSON object per line.
    Process {
        id: save

        command: ["sh", "-c", "hyprctl -j getoption decoration:blur:size && hyprctl -j getoption decoration:blur:passes"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = text.trim().split("\n").map(line => JSON.parse(line));
                    root.saved = { size: lines[0].int, passes: lines[1].int };
                } catch (e) {
                    console.warn("Reading blur settings failed:", e);
                    return;
                }
                if (root.active)
                    raise.running = true;
                else
                    root.restore();
            }
        }
    }

    Process {
        id: raise

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
}

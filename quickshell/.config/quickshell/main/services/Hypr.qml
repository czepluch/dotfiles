pragma Singleton

// Keeps Quickshell's Hyprland state current for events that Quickshell 0.3.2
// does not handle (workspaces moved between monitors, renamed or renumbered,
// special workspaces, monitor hotplug), and reports which special workspace
// is open on each monitor.
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    // Monitor name -> name of its open special workspace, without "special:".
    readonly property var specials: {
        const map = {};
        for (const monitor of Hyprland.monitors.values) {
            const name = monitor.lastIpcObject?.specialWorkspace?.name ?? "";
            if (name !== "")
                map[monitor.name] = name.replace(/^special:/, "");
        }
        return map;
    }

    function specialOn(monitorName) {
        return specials[monitorName] ?? "";
    }

    function focus(workspace) {
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + JSON.stringify(workspace) + " })");
    }

    Component.onCompleted: Hyprland.refreshMonitors()

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            switch (event.name) {
            case "activespecial":
                Hyprland.refreshMonitors();
                break;
            case "moveworkspacev2":
            case "changeworkspaceid":
            case "renameworkspace":
            case "monitoraddedv2":
            case "monitorremovedv2":
                Hyprland.refreshMonitors();
                Hyprland.refreshWorkspaces();
                break;
            }
        }
    }
}

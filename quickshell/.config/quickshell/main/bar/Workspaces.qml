pragma ComponentBehavior: Bound

// Workspace cells for one monitor. Workspaces 1-5 are always shown, plus any
// other workspace that exists. The workspace on this monitor is filled, one
// shown on another monitor is outlined, an urgent one is inverted and
// hatched. Clicking a cell switches to it; scrolling moves through the
// monitor's workspaces one notch at a time.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.components
import qs.services

Row {
    id: root

    required property ShellScreen screen
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    readonly property list<int> ids: {
        const ids = new Set([1, 2, 3, 4, 5]);
        for (const workspace of Hyprland.workspaces.values) {
            if (workspace.id > 0)
                ids.add(workspace.id);
        }
        return [...ids].sort((a, b) => a - b);
    }

    spacing: Style.buttonInset

    WheelSteps {
        onStepped: direction => Hypr.focus(direction > 0 ? "e-1" : "e+1")
    }

    Repeater {
        model: ScriptModel {
            values: root.ids
        }

        Clickable {
            id: cell

            required property int modelData
            readonly property HyprlandWorkspace workspace: Hyprland.workspaces.values.find(w => w.id === modelData) ?? null
            readonly property bool current: root.monitor?.activeWorkspace?.id === modelData
            readonly property bool shownElsewhere: !current && (workspace?.active ?? false)
            readonly property bool occupied: (workspace?.toplevels.values.length ?? 0) > 0
            readonly property bool urgent: workspace?.urgent ?? false

            implicitWidth: Style.buttonSize
            implicitHeight: Style.buttonSize
            baseColor: urgent ? Theme.foreground : current ? Theme.accentFill : "transparent"
            outline: shownElsewhere ? Theme.dim : "transparent"
            hatch: urgent
            onClicked: Hypr.focus(modelData)

            Label {
                anchors.fill: parent
                text: cell.modelData
                bold: cell.current || cell.urgent
                color: cell.urgent ? Theme.background
                    : cell.current ? Theme.onAccent
                    : cell.occupied || cell.shownElsewhere ? Theme.foreground
                    : Theme.dim
            }
        }
    }
}

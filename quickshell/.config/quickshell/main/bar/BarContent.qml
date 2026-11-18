pragma ComponentBehavior: Bound

// Everything drawn in one bar: the surface, the workspaces on the left, the
// hub in the middle, and the tray, chips, hardware panel and control icons
// on the right, plus the dashboard and control panel popups.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import qs
import qs.components
import qs.services

Item {
    id: root

    required property QsWindow window
    required property ShellScreen screen
    // A bar at the bottom of the screen opens its popups upwards.
    property bool atBottom: false
    readonly property string special: Hypr.specialOn(Hyprland.monitorFor(screen)?.name ?? "")

    Surface {
        anchors {
            fill: parent
            leftMargin: Style.screenMargin
            rightMargin: Style.screenMargin
            topMargin: root.atBottom ? 0 : Style.screenMargin
            bottomMargin: root.atBottom ? Style.screenMargin : 0
        }

        Row {
            id: leftGroup

            anchors {
                left: parent.left
                leftMargin: Style.inset
                verticalCenter: parent.verticalCenter
            }
            spacing: Style.buttonInset

            CutRect {
                width: workspaces.implicitWidth + 2 * Style.buttonInset
                height: Style.pillHeight
                color: Theme.glass
                edge: "raised"

                Workspaces {
                    id: workspaces

                    anchors.centerIn: parent
                    screen: root.screen
                }
            }

            // The special workspace (scratchpad) while it is open on this monitor.
            Chip {
                visible: root.special !== ""
                text: root.special
            }
        }

        Hub {
            id: hub

            anchors.fill: parent
            leftLimit: leftGroup.x + leftGroup.width
            rightLimit: rightGroup.x
            onOpenDashboard: dashboard.toggle()
        }

        Row {
            id: rightGroup

            anchors {
                right: parent.right
                rightMargin: Style.inset
                verticalCenter: parent.verticalCenter
            }
            spacing: Style.buttonInset

            Tray {
                visible: SystemTray.items.values.length > 0
                rightPadding: Style.textPadding
                window: root.window
            }

            Chip {
                visible: Keyboard.layout !== "EN" && Keyboard.layout !== ""
                text: Keyboard.layout
            }

            // Chips for the toggles that are on.
            Repeater {
                model: ScriptModel {
                    values: Array.from(ToggleList.items).filter(item => item.chip !== "" && item.on)
                }

                Chip {
                    required property ToggleItem modelData

                    text: modelData.chip
                    icon: modelData.chipIcon
                }
            }

            Readouts {}

            Controls {
                id: controls

                onOpenPanel: panel.toggle()
            }
        }
    }

    Dashboard {
        id: dashboard

        bar: root.window
        anchorItem: hub.timeItem
        opensUp: root.atBottom
    }

    ControlPanel {
        id: panel

        bar: root.window
        anchorItem: controls
        opensUp: root.atBottom
    }
}

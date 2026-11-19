pragma ComponentBehavior: Bound

// Everything drawn in one bar: the surface, the workspaces and the Hacker
// News headline on the left, the hub (time) in the middle, and the tray,
// chips, ETH price, hardware panel and control icons on the right, plus the
// dashboard, system panel and control panel popups. The bar takes barHeight
// at the top of this item (the bottom with atBottom), and an open popup sits
// right under it (above it).
//
// The lock screen shows the same bar with `locked` set: a lock symbol in
// place of the workspaces, no headline, tray or hub (the lock screen draws
// the time itself, starting from hubRect), status kept but not clickable,
// and no popups.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import qs
import qs.components
import qs.services

Item {
    id: root

    // The bar window, for popups and tray menus; null on the lock screen.
    required property QsWindow window
    required property ShellScreen screen
    // A bar at the bottom of the screen opens its popups upwards.
    property bool atBottom: false
    property bool locked: false
    // Narrower screens get a shorter headline and no ETH 24 h change.
    readonly property bool compact: screen.width < Style.compactWidth
    readonly property string special: Hypr.specialOn(Hyprland.monitorFor(screen)?.name ?? "")
    // The hub's time display in this item's coordinates.
    readonly property rect hubRect: Qt.rect(surface.x + hub.displayX,
        surface.y + Math.round((surface.height - Style.pillHeight) / 2), hub.timeWidth, Style.pillHeight)
    // The bar's height, margin to the screen edge included.
    readonly property int barHeight: Style.height + Style.screenMargin
    readonly property var popups: [dashboard.item, system.item, panel.item]
    // At most one popup is open at a time.
    readonly property Item openPopup: popups.find(popup => popup?.visible) ?? null
    // The bar's strip in this item's coordinates, for the input region.
    readonly property rect barRect: Qt.rect(0, atBottom ? height - barHeight : 0, width, barHeight)

    // Opens or closes a popup, closing the others: each one attaches to the
    // bar, and two side by side would overlap. The new popup opens before
    // the old one closes, so that a switch keeps the focus grab.
    function togglePopup(popup) {
        if (!popup)
            return;
        popup.toggle();
        for (const other of popups) {
            if (other && other !== popup)
                other.visible = false;
        }
    }

    function popupNamed(name) {
        return { dashboard: dashboard.item, system: system.item, panel: panel.item }[name] ?? null;
    }

    function closePopups() {
        for (const popup of popups) {
            if (popup)
                popup.visible = false;
        }
    }

    // Closes the open popup on a click outside the bar's window, and gives
    // the window the keyboard while the popup is open (see Bar).
    HyprlandFocusGrab {
        active: root.window !== null && root.openPopup !== null
        windows: root.window ? [root.window] : []
        onCleared: root.closePopups()
    }

    Surface {
        id: surface

        x: Style.screenMargin
        y: root.atBottom ? root.height - root.barHeight : Style.screenMargin
        width: root.width - 2 * Style.screenMargin
        height: Style.height
        up: root.atBottom
        // An opening for each open popup.
        openings: root.popups
            .filter(popup => popup?.visible)
            .map(popup => ({
                left: popup.x - x,
                right: popup.x + popup.width - x
            }))

        Row {
            id: leftGroup

            anchors {
                left: parent.left
                leftMargin: Style.inset
                verticalCenter: parent.verticalCenter
            }
            spacing: Style.buttonInset

            RoundRect {
                visible: !root.locked
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
                visible: !root.locked && root.special !== ""
                text: root.special
            }

            RoundRect {
                visible: root.locked
                width: lockIcon.implicitWidth + 2 * Style.textPadding
                height: Style.pillHeight
                color: Theme.glass
                edge: "raised"

                Label {
                    id: lockIcon

                    anchors.fill: parent
                    text: "󰌾"
                }
            }
        }

        // After the workspaces, up to the hub. Outside the left group, so the
        // hub's position does not depend on the headline's width.
        Headline {
            shown: !root.locked
            x: leftGroup.x + leftGroup.width + Style.buttonInset
            anchors.verticalCenter: parent.verticalCenter
            maxWidth: hub.displayX - hub.gap - x
            maxChars: root.compact ? Style.compactHeadlineChars : 0
        }

        Hub {
            id: hub

            visible: !root.locked
            anchors.fill: parent
            leftLimit: leftGroup.x + leftGroup.width
            rightLimit: rightGroup.x
            onOpenDashboard: root.togglePopup(dashboard.item)
        }

        Row {
            id: rightGroup

            anchors {
                right: parent.right
                rightMargin: Style.inset
                verticalCenter: parent.verticalCenter
            }
            spacing: Style.buttonInset

            Loader {
                active: !root.locked && SystemTray.items.values.length > 0
                visible: active

                sourceComponent: Tray {
                    rightPadding: Style.textPadding
                    window: root.window
                }
            }

            Chip {
                visible: Keyboard.layout !== "EN" && Keyboard.layout !== ""
                text: Keyboard.layout
                fill: Theme.accentFill
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
                    fill: modelData.chipColor
                }
            }

            EthTicker {
                showChange: !root.compact
            }

            Readouts {
                id: readouts

                enabled: !root.locked
                onClicked: root.togglePopup(system.item)
            }

            Controls {
                id: controls

                enabled: !root.locked
                onOpenPanel: root.togglePopup(panel.item)
            }
        }
    }

    Loader {
        id: dashboard

        active: !root.locked

        sourceComponent: Dashboard {
            y: root.atBottom ? surface.y - height : surface.y + surface.height
            barLeft: surface.x
            barRight: surface.x + surface.width
            centerX: surface.x + hub.displayX + hub.timeWidth / 2
            opensUp: root.atBottom
        }
    }

    Loader {
        id: system

        active: !root.locked

        sourceComponent: SystemPanel {
            y: root.atBottom ? surface.y - height : surface.y + surface.height
            barLeft: surface.x
            barRight: surface.x + surface.width
            centerX: surface.x + rightGroup.x + readouts.x + readouts.width / 2
            opensUp: root.atBottom
        }
    }

    Loader {
        id: panel

        active: !root.locked

        sourceComponent: ControlPanel {
            y: root.atBottom ? surface.y - height : surface.y + surface.height
            barLeft: surface.x
            barRight: surface.x + surface.width
            opensUp: root.atBottom
        }
    }
}

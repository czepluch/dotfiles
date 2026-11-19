pragma ComponentBehavior: Bound

// The bar: one panel window along the top of every screen (or the bottom),
// with a fixed reserved height so nothing in it ever moves windows. Its
// content is BarContent. The window is as tall as the screen, so that a
// popup opens inside it without a resize (a resize ends the focus grab that
// closes it), but it takes clicks only on the bar, the open popup and what
// drops down under the clock. While a popup is open it accepts the keyboard
// on demand, and the focus grab hands it over, for Escape. While keep awake
// is on, each bar holds an idle inhibitor. Notifications pop up below the
// clock unless a dashboard is open.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components
import qs.services

Scope {
    id: root

    // Places the bar along the bottom edge instead of the top.
    property bool bottom: false
    // Screens that get a bar.
    property var screens: Quickshell.screens

    // qs -c main ipc call bar toggle <screen> <dashboard|system|panel>
    IpcHandler {
        target: "bar"

        function toggle(screen: string, popup: string): void {
            for (const bar of bars.instances) {
                if (bar.modelData.name === screen)
                    bar.togglePopup(popup);
            }
        }
    }

    Binding {
        target: Notifications
        property: "listOpen"
        value: bars.instances.some(bar => bar.dashboardOpen)
    }

    Variants {
        id: bars

        model: root.screens

        PanelWindow {
            id: barWindow

            required property ShellScreen modelData
            readonly property bool dashboardOpen: content.dashboardOpen

            function togglePopup(name: string) {
                content.togglePopup(content.popupNamed(name));
            }

            screen: modelData
            anchors {
                left: true
                right: true
                top: !root.bottom
                bottom: root.bottom
            }
            implicitHeight: modelData.height
            // One pixel more than the bar's height, for the window shadow to
            // fall on.
            exclusiveZone: content.barHeight + 1
            color: "transparent"
            WlrLayershell.namespace: "quickshell:bar"
            WlrLayershell.keyboardFocus: content.openPopup ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            // Clicks land on the bar, the open popup and what drops down under
            // the clock only.
            mask: Region {
                x: content.barRect.x
                y: content.barRect.y
                width: content.barRect.width
                height: content.barRect.height

                Region {
                    intersection: Intersection.Combine
                    x: content.openPopup?.x ?? 0
                    y: content.openPopup?.y ?? 0
                    width: content.openPopup?.width ?? 0
                    height: content.openPopup?.height ?? 0
                }

                Region {
                    intersection: Intersection.Combine
                    x: content.dropRect.x
                    y: content.dropRect.y
                    width: content.dropRect.width
                    height: content.dropRect.height
                }
            }

            BarContent {
                id: content

                anchors.fill: parent
                window: barWindow
                screen: barWindow.modelData
                atBottom: root.bottom
            }

            IdleInhibitor {
                window: barWindow
                enabled: Session.keepAwake
            }
        }
    }
}

pragma ComponentBehavior: Bound

// The bar: one panel window along the top of every screen (or the bottom),
// with a fixed reserved height so nothing in it ever moves windows. Its
// content is BarContent. While keep awake is on, each bar holds an idle
// inhibitor.
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.services

Scope {
    id: root

    // Places the bar along the bottom edge instead of the top.
    property bool bottom: false
    // Screens that get a bar.
    property var screens: Quickshell.screens

    Variants {
        model: root.screens

        PanelWindow {
            id: barWindow

            required property ShellScreen modelData

            screen: modelData
            anchors {
                left: true
                right: true
                top: !root.bottom
                bottom: root.bottom
            }
            implicitHeight: Style.height + Style.screenMargin
            // One pixel more than the bar's height, for the window shadow to
            // fall on.
            exclusiveZone: implicitHeight + 1
            color: "transparent"
            WlrLayershell.namespace: "quickshell:bar"

            BarContent {
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

pragma ComponentBehavior: Bound

// The center of the bar: the time with seconds and, after a divider, the
// date in a sunken display, in the middle of the screen while there is room. Short messages
// from Osd (volume, layout, the idle lock countdown) replace the time.
// Clicking it opens the dashboard.
import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

Item {
    id: root

    // Free horizontal space in this item's coordinates: right of the left
    // group and left of the right group.
    property real leftLimit: 0
    property real rightLimit: width
    // The display, for anchoring the dashboard and placing the headline.
    readonly property Item timeItem: display
    readonly property int gap: Style.buttonInset
    readonly property int timeWidth: 260
    // In the middle, moved aside when a group needs the room.
    readonly property real displayX: {
        const centered = Math.round(width / 2 - timeWidth / 2);
        return Math.max(leftLimit + gap, Math.min(centered, rightLimit - gap - timeWidth));
    }

    signal openDashboard()

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }

    Connections {
        target: Session

        function onResumed() {
            clock.enabled = false;
            clock.enabled = true;
        }
    }

    RoundRect {
        id: display

        x: root.displayX
        width: root.timeWidth
        height: Style.pillHeight
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.glass
        edge: "sunken"
        clip: true

        HubView {
            anchors.fill: parent
            shown: Osd.message === ""

            Label {
                text: Qt.formatTime(clock.date, "HH:mm:ss")
                color: Theme.accentFill
                bold: true
            }

            Divider {}

            Label {
                text: Qt.formatDate(clock.date, "ddd d MMM")
            }
        }

        HubView {
            anchors.fill: parent
            shown: Osd.message === "volume"

            Label {
                text: Audio.icon
            }

            Item {
                implicitWidth: meter.width
                implicitHeight: Style.pillHeight

                SegMeter {
                    id: meter

                    anchors.verticalCenter: parent.verticalCenter
                    segments: 10
                    value: Audio.muted ? 0 : Audio.volume
                }
            }

            Label {
                text: Audio.muted ? "MUTED" : String(Audio.percent).padStart(3, " ")
            }
        }

        HubView {
            anchors.fill: parent
            shown: Osd.message === "layout"

            Chip {
                text: Keyboard.layout
                fill: Theme.accentFill
            }

            Label {
                text: Keyboard.shortName
            }
        }

        // The last seconds before the idle lock, inverted.
        HubView {
            anchors.fill: parent
            shown: Osd.message === "lock"

            RoundRect {
                anchors.fill: parent
                anchors.topMargin: Style.buttonInset
                anchors.bottomMargin: Style.buttonInset
                radius: Style.cellRadius
                color: Theme.foreground
            }
        }

        HubView {
            anchors.fill: parent
            shown: Osd.message === "lock"

            Label {
                text: "󰌾"
                color: Theme.background
            }

            Label {
                text: "Locking in"
                caps: true
                capHeight: Style.capHeight
                color: Theme.background
            }

            Label {
                text: Osd.lockRemaining
                bold: true
                color: Theme.background
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openDashboard()
        }
    }
}

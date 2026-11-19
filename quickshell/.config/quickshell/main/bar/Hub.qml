pragma ComponentBehavior: Bound

// The center of the bar: the time with seconds and, after a divider, the
// date, as text on the bar in the middle of the screen while there is room.
// Clicking anywhere in its area opens the dashboard.
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

    Item {
        id: display

        x: root.displayX
        width: root.timeWidth
        height: Style.pillHeight
        anchors.verticalCenter: parent.verticalCenter

        Row {
            anchors.centerIn: parent
            spacing: Style.popupSpacing

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

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openDashboard()
        }
    }
}

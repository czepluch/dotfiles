pragma ComponentBehavior: Bound

// A level from 0 to 1 shown as a row of segments.
import QtQuick
import qs

Row {
    id: root

    property real value: 0
    property int segments: 12
    property int segmentWidth: 7
    property int segmentHeight: 13
    property color color: Theme.accentFill
    property color offColor: Theme.off

    spacing: 2

    Repeater {
        model: root.segments

        Rectangle {
            required property int index

            width: root.segmentWidth
            height: root.segmentHeight
            color: index < Math.round(root.value * root.segments) ? root.color : root.offColor
        }
    }
}

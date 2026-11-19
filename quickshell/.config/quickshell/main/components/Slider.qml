// A segmented meter that can be clicked, dragged or scrolled to set a value
// from 0 to 1. The segments fill the slider's width; clicks map onto the
// segments' own width.
import QtQuick
import qs

Item {
    id: root

    property real value: 0
    property int segments: 30

    signal moved(real value)

    function moveTo(v) {
        moved(Math.max(0, Math.min(1, v)));
    }

    implicitHeight: 22

    SegMeter {
        id: meter

        anchors.verticalCenter: parent.verticalCenter
        value: root.value
        segments: root.segments
        segmentWidth: Math.max(2, Math.floor((root.width - (root.segments - 1) * spacing) / root.segments))
        segmentHeight: 14
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root.moveTo(mouse.x / meter.width)
        onPositionChanged: mouse => {
            if (pressed)
                root.moveTo(mouse.x / meter.width);
        }
    }

    WheelSteps {
        onStepped: direction => root.moveTo(root.value + direction * Style.wheelValueStep)
    }
}

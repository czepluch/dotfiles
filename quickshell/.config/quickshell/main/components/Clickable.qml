// A round-cornered area that highlights on hover and reports clicks (any mouse
// button) and, when wheelEnabled is set, wheel steps; otherwise wheel events
// pass to the items underneath. While disabled it neither highlights nor
// shows the hand cursor (Qt still delivers hover to a disabled item).
// Content placed inside it sits on top of the fill.
import QtQuick
import qs

RoundRect {
    id: root

    // Fill when not hovered.
    property color baseColor: "transparent"
    readonly property bool hovered: mouseArea.containsMouse && enabled
    property bool wheelEnabled: false

    signal clicked(var mouse)
    signal stepped(int direction)

    radius: Style.cellRadius
    color: hovered ? Qt.tint(baseColor, Theme.hover) : baseColor

    Behavior on color {
        ColorAnimation {
            duration: root.hovered ? Style.hoverIn : Style.hoverOut
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: mouse => root.clicked(mouse)
    }

    WheelSteps {
        enabled: root.wheelEnabled
        onStepped: direction => root.stepped(direction)
    }
}

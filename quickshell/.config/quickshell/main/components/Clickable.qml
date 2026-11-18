// A cut-corner area that highlights on hover and reports clicks (any mouse
// button) and, when wheelEnabled is set, wheel steps; otherwise wheel events
// pass to the items underneath. Content placed inside it sits on top of the
// fill.
import QtQuick
import qs

CutRect {
    id: root

    // Fill when not hovered.
    property color baseColor: "transparent"
    readonly property bool hovered: mouseArea.containsMouse
    property bool wheelEnabled: false

    signal clicked(var mouse)
    signal stepped(int direction)

    cut: Style.cellCut
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
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: mouse => root.clicked(mouse)
    }

    WheelSteps {
        enabled: root.wheelEnabled
        onStepped: direction => root.stepped(direction)
    }
}

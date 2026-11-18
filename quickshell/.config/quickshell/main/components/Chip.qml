// A short inverted label for a state that is shown only while it is true,
// such as a muted microphone, filled with a color that says what kind of
// state it is. As tall as a bar panel, with the chip centered.
import QtQuick
import qs

Item {
    id: root

    property string text: ""
    property string icon: ""
    property color fill: Theme.foreground

    implicitWidth: chip.width
    implicitHeight: Style.pillHeight

    CutRect {
        id: chip

        anchors.verticalCenter: parent.verticalCenter
        width: row.implicitWidth + 2 * Style.chipPadding
        height: Style.chipHeight
        cut: Style.cellCut
        color: root.fill

        Row {
            id: row

            anchors.centerIn: parent
            spacing: 5

            Label {
                visible: root.icon !== ""
                height: chip.height
                text: root.icon
                size: Style.labelSize
                color: Theme.textOn(root.fill)
            }

            Label {
                height: chip.height
                text: root.text
                caps: true
                bold: true
                color: Theme.textOn(root.fill)
            }
        }
    }
}

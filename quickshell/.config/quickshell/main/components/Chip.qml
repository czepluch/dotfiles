// A short inverted label for a state that is shown only while it is true,
// such as a muted microphone. As tall as a bar panel, with the chip centered.
import QtQuick
import qs

Item {
    id: root

    property string text: ""
    property string icon: ""

    implicitWidth: chip.width
    implicitHeight: Style.pillHeight

    CutRect {
        id: chip

        anchors.verticalCenter: parent.verticalCenter
        width: row.implicitWidth + 2 * Style.chipPadding
        height: Style.chipHeight
        cut: Style.cellCut
        color: Theme.foreground

        Row {
            id: row

            anchors.centerIn: parent
            spacing: 5

            Label {
                visible: root.icon !== ""
                height: chip.height
                text: root.icon
                size: Style.labelSize
                color: Theme.background
            }

            Label {
                height: chip.height
                text: root.text
                caps: true
                bold: true
                color: Theme.background
            }
        }
    }
}

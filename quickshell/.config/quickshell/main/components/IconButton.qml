// A square icon button, highlighted on hover.
import QtQuick
import qs

Clickable {
    id: root

    property string icon: ""
    property color iconColor: Theme.foreground

    implicitWidth: Style.buttonSize
    implicitHeight: Style.buttonSize

    Label {
        anchors.fill: parent
        text: root.icon
        color: root.iconColor
    }
}

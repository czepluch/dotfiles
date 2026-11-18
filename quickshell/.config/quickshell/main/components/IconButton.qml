// A square icon button, highlighted on hover. With text set, the text
// follows the icon and the button widens to fit it.
import QtQuick
import qs

Clickable {
    id: root

    property string icon: ""
    property color iconColor: Theme.foreground
    property string text: ""
    property color textColor: Theme.foreground

    implicitWidth: text === "" ? Style.buttonSize : textLabel.x + textLabel.implicitWidth + Style.textPadding - Style.buttonInset
    implicitHeight: Style.buttonSize

    Label {
        width: Style.buttonSize
        height: parent.height
        text: root.icon
        color: root.iconColor
    }

    Label {
        id: textLabel

        visible: root.text !== ""
        x: Style.buttonSize - Style.buttonInset
        height: parent.height
        text: root.text
        color: root.textColor
    }
}

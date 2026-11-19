// A button with an on and off state: filled with the accent while checked,
// a raised panel while not. Half transparent while disabled.
import QtQuick
import qs

Clickable {
    id: root

    property string text: ""
    property bool checked: false

    implicitWidth: buttonLabel.implicitWidth + 2 * Style.textPadding
    implicitHeight: Style.pillHeight
    radius: Style.panelRadius
    baseColor: checked ? Theme.accentFill : Theme.glass
    edge: checked ? "flat" : "raised"
    opacity: enabled ? 1 : 0.5

    Label {
        id: buttonLabel

        anchors.fill: parent
        text: root.text
        caps: true
        color: root.checked ? Theme.onAccent : Theme.foreground
    }
}

// A label and value in the readouts panel. The value is yellow while high
// (warn) and red while critical (alert). The padding on both sides keeps
// the groups evenly spaced.
import QtQuick
import qs
import qs.components

Item {
    id: root

    property string label: ""
    property string value: ""
    // Colors of the value and label while normal.
    property color color: Theme.foreground
    property color labelColor: Theme.dim
    property bool warn: false
    property bool alert: false

    implicitWidth: pair.implicitWidth + 2 * Style.alertPadding
    implicitHeight: Style.pillHeight

    LabelValue {
        id: pair

        anchors.centerIn: parent
        label: root.label
        value: root.value
        labelColor: root.labelColor
        valueColor: root.alert ? Theme.bad : root.warn ? Theme.warn : root.color
    }
}

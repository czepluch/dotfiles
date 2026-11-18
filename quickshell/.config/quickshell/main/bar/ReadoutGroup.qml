// A label and value in the readouts panel. In the alert state it inverts
// (foreground fill, background text) with a diagonal hatch. The space for
// the alert fill is always reserved, so the panel never changes width.
import QtQuick
import qs
import qs.components

Item {
    id: root

    property string label: ""
    property string value: ""
    // Shown in the warning color; alert inverts instead.
    property bool warn: false
    property bool alert: false

    implicitWidth: pair.implicitWidth + 2 * Style.alertPadding
    implicitHeight: Style.pillHeight

    CutRect {
        visible: root.alert
        anchors {
            fill: parent
            topMargin: Style.buttonInset
            bottomMargin: Style.buttonInset
        }
        cut: Style.cellCut
        color: Theme.foreground
        hatch: true
    }

    LabelValue {
        id: pair

        anchors.centerIn: parent
        label: root.label
        value: root.value
        labelColor: root.alert ? Theme.background : Theme.dim
        valueColor: root.alert ? Theme.background : root.warn ? Theme.warn : Theme.foreground
    }
}

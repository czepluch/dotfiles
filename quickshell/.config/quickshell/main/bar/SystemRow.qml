// One row of the system panel: an uppercase label, a value, a visual such
// as a graph or meter, and a detail on the right. The panel sets the column
// widths so all rows line up. In the alert state the value inverts with
// the alert hatch, which extends past the value column into the padding.
import QtQuick
import qs
import qs.components

Item {
    id: root

    property string label: ""
    property string value: ""
    property string detail: ""
    // Shown in the warning color; alert inverts instead.
    property bool warn: false
    property bool alert: false
    property int labelWidth: 0
    property int valueWidth: 0
    property int detailWidth: 0
    // The visual, placed in its column and centered vertically.
    default property alias visual: visualArea.data

    implicitHeight: Style.rowHeight

    Label {
        height: parent.height
        text: root.label
        caps: true
        capHeight: Style.smallCap
    }

    Item {
        id: valueArea

        x: root.labelWidth + Style.textPadding
        width: root.valueWidth
        height: parent.height

        CutRect {
            visible: root.alert
            anchors {
                fill: parent
                topMargin: Style.buttonInset
                bottomMargin: Style.buttonInset
                leftMargin: -Style.alertPadding
                rightMargin: -Style.alertPadding
            }
            cut: Style.cellCut
            color: Theme.foreground
            hatch: true
        }

        Label {
            anchors.right: parent.right
            height: parent.height
            text: root.value
            size: Style.smallSize
            color: root.alert ? Theme.background : root.warn ? Theme.warn : Theme.foreground
        }
    }

    Item {
        id: visualArea

        x: valueArea.x + valueArea.width + Style.textPadding
        width: root.width - x - (root.detailWidth > 0 ? root.detailWidth + Style.textPadding : 0)
        height: parent.height
    }

    Label {
        anchors.right: parent.right
        height: parent.height
        text: root.detail
        size: Style.smallSize
        color: Theme.dim
        maxWidth: root.detailWidth
    }
}

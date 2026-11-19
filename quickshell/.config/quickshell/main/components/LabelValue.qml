// An uppercase label followed by a value, on the baseline of bar text.
import QtQuick
import qs

Row {
    id: root

    property string label: ""
    property string value: ""
    property color labelColor: Theme.dim
    property color valueColor: Theme.foreground
    // Longer values are cut off with "…". 0 means no limit.
    property int maxValueWidth: 0

    spacing: Style.labelSpacing

    Label {
        text: root.label
        caps: true
        capHeight: Style.capHeight
        color: root.labelColor
    }

    Label {
        text: root.value
        color: root.valueColor
        maxWidth: root.maxValueWidth
    }
}

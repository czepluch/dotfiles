// A bar graph of recent values, newest at the right, in a glass panel. Values are mapped from minimum..maximum to the inner height; the
// graph shows as many of the newest values as fit its width. Bars at or
// above warnAt are in the warning color, at or above alertAt in red.
import QtQuick
import qs

RoundRect {
    id: root

    // Oldest first.
    property var values: []
    property real minimum: 0
    property real maximum: 1
    property color barColor: Theme.accentFill
    property real warnAt: NaN
    property real alertAt: NaN
    property int barWidth: 2
    property int barGap: 1
    readonly property int padding: 2
    readonly property int count: Math.max(0, Math.floor((width - 2 * padding + barGap) / (barWidth + barGap)))

    implicitHeight: Style.rowHeight - 2 * Style.buttonInset
    radius: Style.cellRadius
    color: Theme.glass

    Repeater {
        model: root.count

        Rectangle {
            required property int index
            readonly property int sample: root.values.length - root.count + index
            readonly property real value: sample < 0 ? 0 : root.values[sample]
            readonly property real level: sample < 0 ? 0
                : Math.min(1, Math.max(0, (value - root.minimum) / (root.maximum - root.minimum)))

            visible: sample >= 0
            x: root.width - root.padding - (root.count - index) * (root.barWidth + root.barGap) + root.barGap
            width: root.barWidth
            height: Math.max(1, Math.round(level * (root.height - 2 * root.padding)))
            y: root.height - root.padding - height
            color: value >= root.alertAt ? Theme.bad : value >= root.warnAt ? Theme.warn : root.barColor
        }
    }
}

pragma ComponentBehavior: Bound

// The load of each CPU as a vertical bar, in groups by maximum clock
// (fastest first) with a wider gap between groups. The bars share the
// width evenly, and the gaps between groups take up what is left over, so
// the last bar ends at the right edge. A CPU above the warning level is
// in the warning color.
import QtQuick
import qs
import qs.components
import qs.services

Item {
    id: root

    readonly property int coreCount: Stats.coreGroups.reduce((n, group) => n + group.length, 0)
    readonly property int groupCount: Stats.coreGroups.length
    readonly property int gap: 1
    readonly property int minGroupGap: 6
    readonly property int barWidth: coreCount === 0 ? 0
        : Math.floor((width - (coreCount - groupCount) * gap - (groupCount - 1) * minGroupGap) / coreCount)
    readonly property int groupGap: groupCount < 2 ? 0
        : Math.floor((width - coreCount * barWidth - (coreCount - groupCount) * gap) / (groupCount - 1))

    implicitHeight: Style.rowHeight - 2 * Style.buttonInset

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.groupGap

        Repeater {
            model: Stats.coreGroups

            Row {
                required property var modelData

                spacing: root.gap

                Repeater {
                    model: parent.modelData

                    Rectangle {
                        required property int modelData

                        width: root.barWidth
                        height: root.height
                        color: Theme.off

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            readonly property real load: Stats.cores[parent.modelData] ?? 0

                            height: Math.round(load * parent.height)
                            color: load >= Stats.cpuWarnLevel ? Theme.warn : Theme.accentFill
                        }
                    }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound

// A month view starting on Monday, with ISO week numbers. Today is filled
// with the accent; days of the previous and next month are faint. The arrows
// or the scroll wheel change the month; clicking the month name returns to
// the current month.
import QtQuick
import qs

Column {
    id: root

    // Any day in the month that is shown.
    property date shown: new Date()
    // The day that is marked as today.
    property date today: new Date()
    readonly property int cellWidth: 40
    // Six weeks of days, starting on the Monday on or before the 1st.
    readonly property var weeks: {
        const first = new Date(shown.getFullYear(), shown.getMonth(), 1);
        const start = new Date(first);
        start.setDate(first.getDate() - (first.getDay() + 6) % 7);
        const result = [];
        for (let w = 0; w < 6; w++) {
            const days = [];
            for (let d = 0; d < 7; d++) {
                const day = new Date(start);
                day.setDate(start.getDate() + w * 7 + d);
                days.push(day);
            }
            result.push({ number: isoWeek(days[0]), days: days });
        }
        return result;
    }

    // ISO 8601 week number.
    function isoWeek(d) {
        const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
        const day = t.getUTCDay() || 7;
        t.setUTCDate(t.getUTCDate() + 4 - day);
        const yearStart = new Date(Date.UTC(t.getUTCFullYear(), 0, 1));
        return Math.ceil(((t - yearStart) / 86400000 + 1) / 7);
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }

    function moveMonth(step) {
        shown = new Date(shown.getFullYear(), shown.getMonth() + step, 1);
    }

    spacing: 4

    WheelSteps {
        onStepped: direction => root.moveMonth(-direction)
    }

    // Previous month, month name, next month.
    Item {
        width: 8 * root.cellWidth
        height: Style.rowHeight

        IconButton {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon: "‹"
            onClicked: root.moveMonth(-1)
        }

        Clickable {
            anchors.centerIn: parent
            width: monthName.implicitWidth + 2 * Style.textPadding
            height: Style.rowHeight
            onClicked: root.shown = new Date()

            Label {
                id: monthName

                anchors.fill: parent
                text: root.shown.toLocaleDateString(Qt.locale("en_GB"), "MMMM yyyy")
                size: Style.smallSize
                bold: true
            }
        }

        IconButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            icon: "›"
            onClicked: root.moveMonth(1)
        }
    }

    Grid {
        columns: 8

        Repeater {
            model: ["", "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

            Label {
                required property string modelData

                width: root.cellWidth
                height: Style.sectionHeight
                text: modelData
                caps: true
            }
        }

        Repeater {
            model: root.weeks.length * 8

            Item {
                id: cell

                required property int index
                readonly property var week: root.weeks[Math.floor(index / 8)]
                readonly property bool isWeek: index % 8 === 0
                readonly property date day: isWeek ? new Date(0) : week.days[index % 8 - 1]
                readonly property bool inMonth: !isWeek && day.getMonth() === root.shown.getMonth()
                readonly property bool today: !isWeek && root.sameDay(day, root.today)

                width: root.cellWidth
                height: Style.rowHeight

                CutRect {
                    visible: cell.today
                    anchors.centerIn: parent
                    width: Style.buttonSize
                    height: Style.rowHeight - 2
                    cut: Style.cellCut
                    color: Theme.accentFill
                }

                // Week numbers share the baseline of the day numbers.
                Label {
                    anchors.fill: parent
                    text: cell.isWeek ? cell.week.number : cell.day.getDate()
                    size: cell.isWeek ? Style.labelSize : Style.smallSize
                    capHeight: Style.smallCap
                    bold: cell.today
                    color: cell.today ? Theme.onAccent
                        : cell.isWeek || !cell.inMonth ? Theme.faint
                        : Theme.foreground
                }
            }
        }
    }
}

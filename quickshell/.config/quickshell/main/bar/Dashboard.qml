pragma ComponentBehavior: Bound

// The dashboard: the time with seconds, today's date and week, the
// timezone, a month calendar, the weather now and for the next 3 days, the
// next tasks from husk, and the notifications, newest first, with a button
// that dismisses them all; the list scrolls when it is long. It opens
// centered under the time in the hub, and a short message from Osd shows at
// its top while the dashboard is open. The calendar starts on the current
// month every time, the timezone and tasks are read again each time it
// opens, and the weather is fetched again when it is older than 30 minutes.
import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

BarPopup {
    id: root

    // The height it can take before it reaches the far edge of the screen;
    // the notification list scrolls to stay within it.
    property real room: Infinity

    onVisibleChanged: {
        if (!visible)
            return;
        calendar.shown = new Date();
        TimeZone.refresh();
        Tasks.refresh();
        Weather.refresh();
    }

    // Ticks only while the dashboard is open.
    SystemClock {
        id: clock

        precision: SystemClock.Seconds
        enabled: root.visible
    }

    OsdRow {
        visible: Osd.message !== ""
        width: calendar.width
    }

    // The time in a glass display.
    RoundRect {
        width: calendar.width
        height: Style.displayHeight
        color: Theme.glass

        Label {
            anchors.fill: parent
            text: Qt.formatTime(clock.date, "HH:mm:ss")
            size: Style.displaySize
            color: Theme.accentFill
            bold: true
        }
    }

    // The date and the timezone, as one group.
    Column {
        Row {
            spacing: Style.textPadding

            Label {
                height: Style.rowHeight
                text: clock.date.toLocaleDateString(Qt.locale("en_GB"), "dddd d MMMM yyyy")
                size: Style.smallSize
            }

            Label {
                height: Style.rowHeight
                text: "week " + calendar.isoWeek(clock.date)
                caps: true
                capHeight: Style.smallCap
            }
        }

        Row {
            spacing: Style.textPadding

            Label {
                height: Style.rowHeight
                text: TimeZone.name.replace(/_/g, " ")
                size: Style.smallSize
            }

            Label {
                height: Style.rowHeight
                text: TimeZone.abbreviation + " UTC" + TimeZone.offset
                caps: true
                capHeight: Style.smallCap
            }
        }
    }

    Calendar {
        id: calendar

        today: clock.date
    }

    Rectangle {
        width: calendar.width
        height: 1
        color: Theme.divider
    }

    SectionLabel {
        text: "Weather"
    }

    // Dimmed when the last forecast is more than an hour old.
    Column {
        opacity: Weather.stale ? 0.6 : 1

        WeatherRow {
            visible: Weather.current !== null && Weather.days.length > 0
            width: calendar.width
            code: Weather.current?.code ?? 0
            isDay: Weather.current?.isDay ?? true
            temperature: Weather.current?.temperature ?? NaN
            high: Weather.days[0]?.high ?? NaN
            low: Weather.days[0]?.low ?? NaN
            rain: Weather.days[0]?.rain ?? 0
        }

        Repeater {
            model: Weather.days.slice(1)

            WeatherRow {
                required property var modelData

                width: calendar.width
                label: modelData.date.toLocaleDateString(Qt.locale("en_GB"), "ddd")
                code: modelData.code
                high: modelData.high
                low: modelData.low
                rain: modelData.rain
            }
        }

        Label {
            visible: Weather.current === null
            height: Style.rowHeight
            text: "No forecast yet"
            size: Style.smallSize
            color: Theme.dim
        }
    }

    Rectangle {
        width: calendar.width
        height: 1
        color: Theme.divider
    }

    SectionLabel {
        text: "Tasks"
    }

    Column {
        Repeater {
            model: Tasks.tasks

            TaskRow {
                required property var modelData

                width: calendar.width
                task: modelData
                now: clock.date
            }
        }

        Label {
            visible: Tasks.tasks.length === 0
            height: Style.rowHeight
            text: Tasks.available ? "Nothing due" : "husk not available"
            size: Style.smallSize
            color: Theme.dim
        }
    }

    Rectangle {
        width: calendar.width
        height: 1
        color: Theme.divider
    }

    Item {
        width: calendar.width
        height: Style.sectionHeight

        SectionLabel {
            text: "Notifications"
        }

        Clickable {
            visible: Notifications.list.length > 0
            anchors.right: parent.right
            anchors.rightMargin: -Style.labelSpacing
            anchors.verticalCenter: parent.verticalCenter
            width: clearLabel.implicitWidth + 2 * Style.labelSpacing
            height: Style.sectionHeight + 4
            onClicked: Notifications.clear()

            Label {
                id: clearLabel

                anchors.centerIn: parent
                height: parent.height
                text: "Clear all"
                caps: true
            }
        }
    }

    ListView {
        visible: count > 0
        width: calendar.width
        height: Math.min(contentHeight, Style.historyHeight,
            Math.max(Style.historyMinHeight, root.room - 2 * Style.popupPadding - y))
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        spacing: Style.popupSpacing
        model: Notifications.list

        delegate: Column {
            id: entry

            required property var modelData
            required property int index

            spacing: Style.popupSpacing

            Rectangle {
                visible: entry.index > 0
                width: calendar.width
                height: 1
                color: Theme.divider
            }

            NotificationRow {
                width: calendar.width
                notification: entry.modelData
            }
        }
    }

    Label {
        visible: Notifications.list.length === 0
        height: Style.rowHeight
        text: "No notifications"
        size: Style.smallSize
        color: Theme.dim
    }
}

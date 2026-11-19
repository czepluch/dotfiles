// One task in the dashboard: when it is due, its summary and its list. The
// due label is in the accent for today and, for an overdue task, inverted
// on a red fill, which extends past the left edge so the text lines up with
// the rest of the popup.
import QtQuick
import qs
import qs.components
import qs.services

Item {
    id: root

    required property var task
    property date now: new Date()

    implicitHeight: Style.rowHeight

    // The due column fits the longest label, "Wed 09:00".
    TextMetrics {
        id: dueMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.smallSize
        text: "Wed 09:00"
    }

    Item {
        id: due

        width: Math.ceil(dueMetrics.advanceWidth)
        height: parent.height

        RoundRect {
            visible: root.task.overdue
            anchors {
                fill: parent
                topMargin: Style.buttonInset
                bottomMargin: Style.buttonInset
                leftMargin: -Style.alertPadding
                rightMargin: -Style.alertPadding
            }
            radius: Style.cellRadius
            color: Theme.bad
        }

        Label {
            height: parent.height
            text: Tasks.dueLabel(root.task, root.now)
            size: Style.smallSize
            color: root.task.overdue ? Theme.textOn(Theme.bad)
                : root.task.due !== null && Tasks.daysBetween(root.now, root.task.due) === 0 ? Theme.accentFill
                : Theme.dim
        }
    }

    Label {
        x: due.width + Style.alertPadding + Style.textPadding
        height: parent.height
        text: root.task.summary
        size: Style.smallSize
        maxWidth: project.x - x - Style.textPadding
    }

    Label {
        id: project

        anchors.right: parent.right
        height: parent.height
        text: root.task.project
        caps: true
        capHeight: Style.smallCap
    }
}

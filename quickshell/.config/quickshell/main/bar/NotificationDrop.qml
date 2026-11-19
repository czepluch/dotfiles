pragma ComponentBehavior: Bound

// What drops down under the clock: the short message from Osd and, on the
// screen with the focused monitor, the notification popups, newest first,
// with dividers between them. It is as wide as the clock's area for a
// message alone. It does not take the keyboard, and the mouse over it
// pauses the popups' timers. BarContent hides it while the dashboard hangs
// in its place or another popup would overlap it.
import QtQuick
import qs
import qs.components
import qs.services

BarPopup {
    id: root

    // On the screen with the focused monitor, where the popups show.
    property bool focused: false
    property bool covered: false
    readonly property bool hasMessage: Osd.message !== ""
    readonly property var popups: focused ? Notifications.popups : []
    readonly property int contentWidth: popups.length > 0 ? Style.notificationWidth : Style.messageWidth

    takesFocus: false
    visible: !covered && (hasMessage || popups.length > 0)

    onHoveredChanged: {
        if (focused)
            Notifications.paused = hovered;
    }

    OsdRow {
        visible: root.hasMessage
        width: root.contentWidth
    }

    Repeater {
        model: root.popups

        Column {
            id: entry

            required property var modelData
            required property int index

            spacing: Style.popupSpacing

            Rectangle {
                visible: entry.index > 0 || root.hasMessage
                width: root.contentWidth
                height: 1
                color: Theme.divider
            }

            NotificationRow {
                width: root.contentWidth
                notification: entry.modelData
            }
        }
    }
}

pragma ComponentBehavior: Bound

// One notification: its icon, the app name and the time it arrived (an ×
// that dismisses it while the mouse is over it), the summary, up to 2 lines
// of the body, and a button for each of its actions. A critical one has its
// app name and summary in red. A left click runs its default action, a
// right click dismisses it.
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs
import qs.components
import qs.services

Item {
    id: root

    required property Notification notification
    readonly property bool critical: notification.urgency === NotificationUrgency.Critical
    readonly property var buttons: notification.actions.filter(a => a.identifier !== "default" && a.text !== "")
    // The image the app sends (often a picture of the sender), else the
    // app's icon, else the icon of its desktop entry.
    readonly property string icon: {
        if (notification.image !== "")
            return notification.image;
        const name = notification.appIcon;
        if (name.startsWith("/"))
            return "file://" + name;
        if (name.includes("://"))
            return name;
        const entry = notification.desktopEntry !== "" ? DesktopEntries.byId(notification.desktopEntry) : null;
        return Quickshell.iconPath(name !== "" ? name : entry?.icon ?? "", true);
    }
    readonly property string appName: notification.appName !== "" ? notification.appName
        : DesktopEntries.byId(notification.desktopEntry)?.name ?? ""

    implicitWidth: Style.notificationWidth
    implicitHeight: Math.max(Style.notificationIcon, column.implicitHeight)

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                Notifications.dismiss(root.notification);
            else
                Notifications.activate(root.notification);
        }
    }

    IconImage {
        visible: root.icon !== ""
        implicitSize: Style.notificationIcon
        source: root.icon
    }

    Label {
        visible: root.icon === ""
        width: Style.notificationIcon
        height: Style.notificationIcon
        text: "󰂚"
        size: Style.notificationIcon - 6
        color: root.critical ? Theme.bad : Theme.foreground
    }

    Column {
        id: column

        x: Style.notificationIcon + Style.textPadding
        width: root.width - x
        spacing: 2

        Item {
            width: parent.width
            height: Style.sectionHeight

            Label {
                height: parent.height
                maxWidth: parent.width - time.width - Style.textPadding
                text: root.appName
                caps: true
                color: root.critical ? Theme.bad : Theme.dim
            }

            Label {
                id: time

                visible: !hover.hovered
                anchors.right: parent.right
                height: parent.height
                text: Qt.formatTime(new Date(Notifications.timeOf(root.notification)), "HH:mm")
                caps: true
            }

            Clickable {
                visible: hover.hovered
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: Style.sectionHeight + 4
                height: Style.sectionHeight + 4
                onClicked: Notifications.dismiss(root.notification)

                Label {
                    anchors.fill: parent
                    text: "󰅖"
                    size: Style.labelSize
                    color: Theme.dim
                }
            }
        }

        Text {
            width: parent.width
            text: root.notification.summary
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: root.critical ? Theme.bad : Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Style.smallSize
            font.bold: true
        }

        Text {
            visible: text !== ""
            width: parent.width
            text: root.notification.body
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Style.smallSize
        }

        Row {
            visible: root.buttons.length > 0
            topPadding: Style.gap
            spacing: Style.gap

            Repeater {
                model: root.buttons

                Clickable {
                    id: button

                    required property NotificationAction modelData

                    width: actionLabel.implicitWidth + 2 * Style.textPadding
                    height: Style.chipHeight + 4
                    baseColor: Theme.glass
                    edge: "raised"
                    onClicked: modelData.invoke()

                    Label {
                        id: actionLabel

                        anchors.centerIn: parent
                        text: button.modelData?.text ?? ""
                        caps: true
                        capHeight: Style.labelCap
                    }
                }
            }
        }
    }
}

// One state of the hub's time part: a centered row that slides down into
// view when shown and up out of view when hidden.
import QtQuick
import qs.components

Item {
    id: root

    default property alias content: row.data
    property bool shown: false

    opacity: shown ? 1 : 0
    visible: opacity > 0

    transform: Translate {
        y: root.shown ? 0 : -Style.slide

        Behavior on y {
            NumberAnimation {
                duration: Style.change
                easing.type: Easing.OutCubic
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Style.change
        }
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: Style.popupSpacing
    }
}

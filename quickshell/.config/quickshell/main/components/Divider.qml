// A thin vertical line between items in a panel. As tall as a bar panel,
// with the line centered.
import QtQuick
import qs

Item {
    implicitWidth: 1
    implicitHeight: Style.pillHeight

    Rectangle {
        anchors.centerIn: parent
        width: 1
        height: Style.dividerHeight
        color: Theme.divider
    }
}

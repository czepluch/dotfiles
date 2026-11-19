// One wallpaper in the wallpaper picker: its preview, the name below it,
// and "current" on the one in use when the picker opened. The selected
// tile has a raised glass fill.
import QtQuick
import qs
import qs.components

Item {
    id: root

    // { name, preview, current }; see LauncherPanel.
    required property var item
    property bool selected: false
    readonly property alias hovered: hover.hovered
    readonly property int padding: Style.launcherEdge

    HoverHandler {
        id: hover
    }

    RoundRect {
        visible: root.selected
        anchors.fill: parent
        radius: Style.panelRadius
        color: Theme.glass
        edge: "raised"
    }

    Rectangle {
        id: picture

        x: root.padding
        y: root.padding
        width: root.width - 2 * root.padding
        height: Math.round(width * 0.625)
        radius: Style.cellRadius
        color: Theme.background
        clip: true

        Image {
            anchors.fill: parent
            source: root.item.preview ?? ""
            sourceSize.width: 480
            sourceSize.height: 300
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        Label {
            visible: (root.item.preview ?? "") === ""
            anchors.fill: parent
            text: "󰋩"
            size: Style.launcherSize
            color: Theme.faint
        }

        RoundRect {
            visible: root.item.current ?? false
            x: root.padding
            y: root.padding
            width: currentLabel.implicitWidth + 2 * Style.launcherEdge
            height: Style.launcherSmallCap + 2 * Style.launcherEdge
            radius: Style.cellRadius
            color: Theme.barFill

            Label {
                id: currentLabel

                anchors.centerIn: parent
                height: parent.height
                text: "current"
                size: Style.launcherSmallSize
            }
        }
    }

    Label {
        x: root.padding
        y: picture.y + picture.height
        width: picture.width
        height: root.height - y - root.padding / 2
        maxWidth: picture.width
        text: root.item.name
        size: Style.launcherSmallSize
        color: root.selected ? Theme.foreground : Theme.dim
    }
}

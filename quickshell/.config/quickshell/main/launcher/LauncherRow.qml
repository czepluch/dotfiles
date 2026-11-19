// One entry of the launcher: an icon, a glyph or an image preview, the name
// and a dim detail after it, with room left at the end for a button
// (trailing). The selected entry has a raised glass fill; an entry that
// waits for a second press to confirm is red and says so.
import QtQuick
import qs
import qs.components

Item {
    id: root

    // { name, detail, icon, glyph, preview }; see LauncherWindow.
    required property var item
    property bool selected: false
    property bool confirming: false
    property int trailing: 0
    readonly property alias hovered: hover.hovered
    readonly property bool hasPreview: (item.preview ?? "") !== ""
    readonly property int leading: hasPreview ? Style.previewWidth : Style.launcherIcon
    readonly property color ink: confirming ? Theme.textOn(Theme.bad) : Theme.foreground

    implicitHeight: hasPreview || item.image ? Style.launcherImageRow : Style.launcherRow

    HoverHandler {
        id: hover
    }

    RoundRect {
        visible: root.selected || root.confirming
        anchors.fill: parent
        radius: Style.cellRadius
        color: root.confirming ? Theme.bad : Theme.glass
        edge: root.confirming ? "flat" : "raised"
    }

    Image {
        visible: (root.item.icon ?? "") !== ""
        x: Style.launcherEdge
        anchors.verticalCenter: parent.verticalCenter
        width: Style.launcherIcon
        height: Style.launcherIcon
        sourceSize.width: 2 * Style.launcherIcon
        sourceSize.height: 2 * Style.launcherIcon
        source: root.item.icon ?? ""
        asynchronous: true
        mipmap: true
    }

    Label {
        visible: (root.item.glyph ?? "") !== ""
        x: Style.launcherEdge
        width: Style.launcherIcon
        height: parent.height
        text: root.item.glyph ?? ""
        size: Style.launcherSize
        color: root.ink
    }

    // The preview keeps its proportions within the box and is centered in it.
    Item {
        visible: root.hasPreview
        x: Style.launcherEdge
        anchors.verticalCenter: parent.verticalCenter
        width: Style.previewWidth
        height: Style.previewHeight

        Image {
            anchors.fill: parent
            source: root.item.preview ?? ""
            sourceSize.width: 2 * Style.previewWidth
            sourceSize.height: 2 * Style.previewHeight
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            mipmap: true
        }
    }

    Label {
        id: nameLabel

        x: Style.launcherEdge + root.leading + Style.launcherInset
        height: parent.height
        maxWidth: root.width - x - Style.launcherEdge - root.trailing
        text: root.item.name
        size: Style.launcherSize
        color: root.ink
    }

    Label {
        x: nameLabel.x + nameLabel.width + Style.launcherInset
        height: parent.height
        maxWidth: root.width - x - Style.launcherEdge - root.trailing
        text: root.confirming ? "Sure?" : root.item.detail ?? ""
        size: Style.launcherSize
        bold: root.confirming
        color: root.confirming ? root.ink : Theme.faint
    }
}

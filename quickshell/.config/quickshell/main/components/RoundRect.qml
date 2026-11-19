// A rectangle with round corners. It can have a 1 px outline and a 1 px
// edge that makes it look raised (light top, dark bottom).
import QtQuick
import qs

Rectangle {
    id: root

    property color outline: "transparent"
    // "flat" or "raised".
    property string edge: "flat"

    readonly property int edgeInset: outline.a > 0 ? 1 : 0

    radius: Style.panelRadius
    color: "transparent"
    border.width: outline.a > 0 ? 1 : 0
    border.color: outline

    // Top edge, along the straight part between the corners.
    Rectangle {
        visible: root.edge !== "flat"
        x: root.radius
        y: root.edgeInset
        width: root.width - 2 * root.radius
        height: 1
        color: Theme.edgeLight
    }

    // Bottom edge.
    Rectangle {
        visible: root.edge !== "flat"
        x: root.radius
        y: root.height - 1 - root.edgeInset
        width: root.width - 2 * root.radius
        height: 1
        color: Theme.edgeDark
    }
}

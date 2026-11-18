// A popup that opens from an item in the bar: below it for a bar at the top,
// above it for a bar at the bottom, either centered on the item or aligned
// to its right edge. It keeps the same gap to the bar as Hyprland keeps
// between windows, and closes on Escape, on a click outside it or the bar,
// or when toggled again. Children are stacked in a padded column.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.components

PopupWindow {
    id: root

    // The bar window and the item the popup opens from.
    required property QsWindow bar
    required property Item anchorItem
    property bool opensUp: false
    property bool alignRight: false
    default property alias content: column.data
    property alias spacing: column.spacing

    function toggle() {
        visible = !visible;
    }

    anchor.window: bar
    anchor.item: anchorItem
    anchor.edges: (opensUp ? Edges.Top : Edges.Bottom) | (alignRight ? Edges.Right : Edges.None)
    anchor.gravity: (opensUp ? Edges.Top : Edges.Bottom) | (alignRight ? Edges.Left : Edges.None)
    anchor.adjustment: PopupAdjustment.Slide
    // Extends the anchor to the edge of the bar window. The gap between the
    // bar and the popup is transparent space inside the popup.
    anchor.margins.top: opensUp ? -Style.inset : 0
    anchor.margins.bottom: opensUp ? 0 : -Style.inset

    implicitWidth: column.implicitWidth + 2 * Style.popupPadding
    implicitHeight: column.implicitHeight + 2 * Style.popupPadding + Style.screenMargin
    color: "transparent"
    visible: false

    HyprlandFocusGrab {
        active: root.visible
        windows: [root, root.bar]
        onCleared: root.visible = false
    }

    Item {
        id: body

        anchors {
            fill: parent
            topMargin: root.opensUp ? 0 : Style.screenMargin
            bottomMargin: root.opensUp ? Style.screenMargin : 0
        }
        focus: true
        Keys.onEscapePressed: root.visible = false

        Surface {
            anchors.fill: parent
            popup: true
        }

        Column {
            id: column

            x: Style.popupPadding
            y: Style.popupPadding
            spacing: Style.popupSpacing
        }
    }
}

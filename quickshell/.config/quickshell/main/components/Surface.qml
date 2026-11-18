// The background of a top-level surface such as the bar or a popup: a
// translucent panel with round corners, an outline and a raised edge.
import QtQuick
import qs

RoundRect {
    // More opaque for popups, which sit over windows.
    property bool popup: false

    radius: Style.surfaceRadius
    color: popup ? Theme.popupFill : Theme.barFill
    outline: Theme.outline
    edge: "raised"
}

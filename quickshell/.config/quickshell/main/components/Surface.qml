// The background of a top-level surface such as the bar or a popup: a
// translucent cut-corner panel with an outline and a raised edge.
import QtQuick
import qs

CutRect {
    // More opaque for popups, which sit over windows.
    property bool popup: false

    cut: Style.cut
    color: popup ? Theme.popupFill : Theme.barFill
    outline: Theme.outline
    edge: "raised"
}

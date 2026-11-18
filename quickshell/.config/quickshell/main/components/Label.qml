// Text in the shell's font. It is centered horizontally, and vertically on
// capHeight with the baseline on a whole pixel. By default that is the cap
// height of its own size; text of different sizes in one row shares a
// baseline when all of it uses the cap height of the row's main size. It is
// as tall as a bar panel unless its parent sets another height. Longer text
// than maxWidth is cut off with "…".
import QtQuick
import qs

Item {
    id: root

    property alias text: label.text
    property alias color: label.color
    // Uppercase with letter spacing, for labels.
    property bool caps: false
    property int size: caps ? Style.labelSize : Style.size
    property bool bold: false
    property int capHeight: Style.capHeightAt(size)
    // 0 means no limit.
    property int maxWidth: 0

    implicitWidth: Math.ceil(label.width)
    implicitHeight: Style.pillHeight

    Text {
        id: label

        width: root.maxWidth > 0 ? Math.min(implicitWidth, root.maxWidth) : implicitWidth
        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height + root.capHeight) / 2) - baselineOffset
        elide: Text.ElideRight
        color: root.caps ? Theme.dim : Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: root.size
        font.bold: root.bold
        font.capitalization: root.caps ? Font.AllUppercase : Font.MixedCase
        font.letterSpacing: root.caps ? Math.round(0.06 * root.size * 10) / 10 : 0
    }
}

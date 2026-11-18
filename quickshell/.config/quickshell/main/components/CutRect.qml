// A rectangle with 45° cut corners. It can have a 1 px outline, a 1 px edge
// that makes it look raised (light top, dark bottom) or sunken (dark top,
// light bottom).
import QtQuick
import QtQuick.Shapes
import qs

Item {
    id: root

    property int cut: Style.panelCut
    property color color: "transparent"
    property color outline: "transparent"
    // "flat", "raised" or "sunken".
    property string edge: "flat"

    readonly property bool hasOutline: outline.a > 0
    // Strokes are centered on the path, so an outlined path runs through
    // pixel centers to keep the 1 px line sharp.
    readonly property real strokeOffset: hasOutline ? 0.5 : 0
    readonly property int edgeInset: hasOutline ? 1 : 0

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: root.hasOutline ? root.outline : "transparent"
            strokeWidth: root.hasOutline ? 1 : -1
            joinStyle: ShapePath.MiterJoin

            PathPolyline {
                path: {
                    const w = root.width;
                    const h = root.height;
                    const c = root.cut;
                    const o = root.strokeOffset;
                    return [
                        Qt.point(c, o), Qt.point(w - c, o), Qt.point(w - o, c), Qt.point(w - o, h - c),
                        Qt.point(w - c, h - o), Qt.point(c, h - o), Qt.point(o, h - c), Qt.point(o, c),
                        Qt.point(c, o)
                    ];
                }
            }
        }
    }

    // Top edge.
    Rectangle {
        visible: root.edge !== "flat"
        x: root.cut
        y: root.edgeInset
        width: root.width - 2 * root.cut
        height: 1
        color: root.edge === "raised" ? Theme.edgeLight : Theme.edgeDeep
    }

    // Bottom edge.
    Rectangle {
        visible: root.edge !== "flat"
        x: root.cut
        y: root.height - 1 - root.edgeInset
        width: root.width - 2 * root.cut
        height: 1
        color: root.edge === "raised" ? Theme.edgeDark : Theme.edgeFaint
    }
}

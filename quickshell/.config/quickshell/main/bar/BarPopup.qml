// A popup attached to the bar: below it for a bar at the top, above it for
// a bar at the bottom, centered on a point of the bar or flush with its
// right end. It continues the bar's surface: the same fill, and an outline
// that curves out of the bar's edge into the popup's sides (the bar leaves
// an opening there, see Surface). Flush with the bar's end, its side runs
// straight on from the bar's side. It closes on Escape, on a click outside
// it or the bar, or when toggled again. Children are stacked in a padded
// column.
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import qs
import qs.components

PopupWindow {
    id: root

    // The bar window, and the horizontal extent of the bar's surface in it.
    required property QsWindow bar
    required property real barLeft
    required property real barRight
    // The point of the bar to center on, in the bar window's coordinates.
    property real centerX: (barLeft + barRight) / 2
    property bool opensUp: false
    // Flush with the bar's right end instead of centered.
    property bool alignRight: false
    default property alias content: column.data
    property alias spacing: column.spacing

    readonly property int join: Style.joinRadius
    readonly property int bodyWidth: column.implicitWidth + 2 * Style.popupPadding
    readonly property int joinLeft: join
    readonly property int joinRight: alignRight ? 0 : join
    // The left edge of this window in the bar window's coordinates, kept
    // clear of the bar's rounded corners.
    readonly property int windowX: alignRight ? Math.round(barRight) - implicitWidth
        : Math.round(Math.max(barLeft + Style.surfaceRadius,
            Math.min(centerX - implicitWidth / 2, barRight - Style.surfaceRadius - implicitWidth)))

    // The fill and the outline as SVG paths, drawn for a popup below the bar
    // and mirrored for one above it. The curves start on the bar's edge,
    // above this window, where the bar draws their first pixels.
    readonly property string fillPath: {
        const w = implicitWidth;
        const h = implicitHeight;
        const r = Style.surfaceRadius;
        const j = join;
        const left = joinLeft;
        const right = joinLeft + bodyWidth;
        let d = joinLeft ? `M 0 0 A ${j} ${j} 0 0 1 ${left} ${j}` : "M 0 0";
        d += ` L ${left} ${h - r} A ${r} ${r} 0 0 0 ${left + r} ${h}`;
        d += ` L ${right - r} ${h} A ${r} ${r} 0 0 0 ${right} ${h - r}`;
        d += joinRight ? ` L ${right} ${j} A ${j} ${j} 0 0 1 ${w} 0` : ` L ${right} 0`;
        return d + " Z";
    }
    readonly property string outlinePath: {
        const w = implicitWidth;
        const h = implicitHeight;
        const r = Style.surfaceRadius;
        const a = r - 0.5;
        const j = join;
        const left = joinLeft + 0.5;
        const right = joinLeft + bodyWidth - 0.5;
        let d = joinLeft ? `M 0.5 -0.5 A ${j} ${j} 0 0 1 ${left} ${j - 0.5}` : `M ${left} -0.5`;
        d += ` L ${left} ${h - r} A ${a} ${a} 0 0 0 ${joinLeft + r} ${h - 0.5}`;
        d += ` L ${joinLeft + bodyWidth - r} ${h - 0.5} A ${a} ${a} 0 0 0 ${right} ${h - r}`;
        d += joinRight ? ` L ${right} ${j - 0.5} A ${j} ${j} 0 0 1 ${w - 0.5} -0.5` : ` L ${right} -0.5`;
        return d;
    }

    function toggle() {
        visible = !visible;
    }

    // Anchored to a point on the bar window's edge.
    anchor.window: bar
    anchor.rect.x: windowX
    anchor.rect.y: opensUp ? 0 : bar.height - 1
    anchor.rect.width: 1
    anchor.rect.height: 1
    anchor.edges: (opensUp ? Edges.Top : Edges.Bottom) | Edges.Left
    anchor.gravity: (opensUp ? Edges.Top : Edges.Bottom) | Edges.Right
    anchor.adjustment: PopupAdjustment.Slide

    implicitWidth: joinLeft + bodyWidth + joinRight
    implicitHeight: column.implicitHeight + 2 * Style.popupPadding
    color: "transparent"
    visible: false

    HyprlandFocusGrab {
        active: root.visible
        windows: [root, root.bar]
        onCleared: root.visible = false
    }

    Item {
        id: body

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.visible = false

        Shape {
            id: shape

            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            transform: Scale {
                origin.y: shape.height / 2
                yScale: root.opensUp ? -1 : 1
            }

            ShapePath {
                fillColor: Theme.barFill
                strokeWidth: -1

                PathSvg {
                    path: root.fillPath
                }
            }

            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.outline
                strokeWidth: 1

                PathSvg {
                    path: root.outlinePath
                }
            }
        }

        // Raised edge on the side away from the bar: a dark line along the
        // bottom, or a light line along the top for a popup above the bar.
        Rectangle {
            x: root.joinLeft + Style.surfaceRadius
            y: root.opensUp ? 1 : parent.height - 2
            width: root.bodyWidth - 2 * Style.surfaceRadius
            height: 1
            color: root.opensUp ? Theme.edgeLight : Theme.edgeDark
        }

        Column {
            id: column

            x: root.joinLeft + Style.popupPadding
            y: Style.popupPadding
            spacing: Style.popupSpacing
        }
    }
}

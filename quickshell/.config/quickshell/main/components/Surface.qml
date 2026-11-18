// The background of the bar: a translucent panel with round corners, an
// outline and a raised edge (light top, dark bottom). Popups attach to the
// edge they open from, the bottom edge or the top edge with `up`. Along each
// opening the outline leaves a gap and curves out of the edge into the
// popup's sides, which BarPopup draws on the same curve. An opening that
// reaches an end of the bar makes that corner square, so the bar's side runs
// straight into the popup's side.
import QtQuick
import QtQuick.Shapes
import qs

Item {
    id: root

    // Openings as { left, right } in this item's coordinates: the horizontal
    // extent of each attached popup window, curves included.
    property var openings: []
    // Popups attach to the top edge instead of the bottom edge.
    property bool up: false

    readonly property int radius: Style.surfaceRadius
    readonly property int join: Style.joinRadius
    readonly property var sorted: openings.slice().sort((a, b) => a.left - b.left)
    readonly property bool openLeft: sorted.some(o => o.left <= 0)
    readonly property bool openRight: sorted.some(o => o.right >= width)
    // Stretches of the edge with the openings that keep their outline, as
    // [from, to] pairs between the corners.
    readonly property var closed: {
        let from = radius;
        let to = width - radius;
        const result = [];
        for (const o of sorted) {
            if (o.left <= 0) {
                from = o.right - 0.5;
                continue;
            }
            if (o.right >= width) {
                to = o.left + 0.5;
                continue;
            }
            if (o.left + 0.5 > from)
                result.push([from, o.left + 0.5]);
            from = o.right - 0.5;
        }
        if (to > from)
            result.push([from, to]);
        return result;
    }
    // The outline as an SVG path, drawn with the openings along the bottom
    // edge and mirrored for `up`. Strokes run through pixel centers.
    readonly property string outlinePath: {
        const w = width;
        const h = height;
        const r = radius;
        const a = r - 0.5;
        const b = h - 0.5;
        const j = join;
        let d = openLeft ? `M 0.5 ${h} L 0.5 ${r}`
            : `M ${r} ${b} A ${a} ${a} 0 0 1 0.5 ${h - r} L 0.5 ${r}`;
        d += ` A ${a} ${a} 0 0 1 ${r} 0.5 L ${w - r} 0.5 A ${a} ${a} 0 0 1 ${w - 0.5} ${r}`;
        d += openRight ? ` L ${w - 0.5} ${h}`
            : ` L ${w - 0.5} ${h - r} A ${a} ${a} 0 0 1 ${w - r} ${b}`;
        for (const [from, to] of closed)
            d += ` M ${from} ${b} L ${to} ${b}`;
        // The start of each curve into a popup; the rest lies below this
        // item, in the popup.
        for (const o of sorted) {
            if (o.left > 0)
                d += ` M ${o.left + 0.5} ${b} A ${j} ${j} 0 0 1 ${o.left + 0.5 + j} ${b + j}`;
            if (o.right < w)
                d += ` M ${o.right - 0.5} ${b} A ${j} ${j} 0 0 0 ${o.right - 0.5 - j} ${b + j}`;
        }
        return d;
    }

    Shape {
        id: shape

        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        transform: Scale {
            origin.y: shape.height / 2
            yScale: root.up ? -1 : 1
        }

        ShapePath {
            fillColor: Theme.barFill
            strokeWidth: -1

            PathRectangle {
                width: root.width
                height: root.height
                topLeftRadius: root.radius
                topRightRadius: root.radius
                bottomLeftRadius: root.openLeft ? 0 : root.radius
                bottomRightRadius: root.openRight ? 0 : root.radius
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

    // Raised edge: a light line along the top and a dark line along the
    // bottom, inside the outline. The line on the edge with the openings
    // keeps only the closed stretches.
    Repeater {
        model: root.up ? root.closed : [[root.radius, root.width - root.radius]]

        Rectangle {
            required property var modelData

            x: Math.round(modelData[0])
            y: 1
            width: Math.round(modelData[1]) - x
            height: 1
            color: Theme.edgeLight
        }
    }

    Repeater {
        model: root.up ? [[root.radius, root.width - root.radius]] : root.closed

        Rectangle {
            required property var modelData

            x: Math.round(modelData[0])
            y: root.height - 2
            width: Math.round(modelData[1]) - x
            height: 1
            color: Theme.edgeDark
        }
    }
}

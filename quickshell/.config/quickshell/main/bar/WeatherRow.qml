// One row of the weather table in the dashboard: a day label (or, in the
// first row, the temperature now), the weather icon and description, the
// high and low, and the chance of rain. Numbers are right-aligned in fixed
// columns, so the rows line up.
import QtQuick
import qs
import qs.components
import qs.services

Item {
    id: root

    property string label: ""
    property int code: 0
    property bool isDay: true
    // Shown in bold instead of the label when set.
    property real temperature: NaN
    property real high: NaN
    property real low: NaN
    property int rain: 0

    // Sun yellow (by day), clouds dim, rain and snow cyan, storms red.
    function iconColor(code, isDay) {
        switch (Weather.kind(code)) {
        case "clear":
        case "partly":
            return isDay ? Theme.readable(Theme.yellow) : Theme.foreground;
        case "cloudy":
            return Theme.dim;
        case "storm":
            return Theme.bad;
        default:
            return Theme.info;
        }
    }

    function degrees(value) {
        return Math.round(value) + "°";
    }

    implicitHeight: Style.rowHeight

    // Column widths. The font is monospaced, so the widest text of each
    // column sets its width.
    TextMetrics {
        id: dayMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.labelSize
        font.letterSpacing: Math.round(0.06 * Style.labelSize * 10) / 10
        text: "WED"
    }

    TextMetrics {
        id: numberMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.smallSize
        text: "-10°"
    }

    // Weather glyphs differ in width and some draw past their advance; each
    // is centered in a column as wide as the drawn cloud glyph.
    TextMetrics {
        id: iconMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.smallSize
        text: "󰖐"
    }

    Item {
        id: day

        width: Math.ceil(Math.max(dayMetrics.advanceWidth, numberMetrics.advanceWidth))
        height: parent.height

        Label {
            visible: isNaN(root.temperature)
            height: parent.height
            text: root.label
            caps: true
            capHeight: Style.smallCap
        }

        Label {
            visible: !isNaN(root.temperature)
            height: parent.height
            text: root.degrees(root.temperature)
            size: Style.smallSize
            bold: true
        }
    }

    Label {
        id: icon

        x: day.width + Style.textPadding
        width: Math.ceil(Math.max(iconMetrics.advanceWidth, iconMetrics.tightBoundingRect.right))
        height: parent.height
        text: Weather.icon(root.code, root.isDay)
        size: Style.smallSize
        color: root.iconColor(root.code, root.isDay)
    }

    Label {
        x: icon.x + icon.width + Style.labelSpacing
        height: parent.height
        text: Weather.describe(root.code)
        size: Style.smallSize
        maxWidth: high.x - x - Style.textPadding
    }

    Item {
        id: high

        anchors.right: low.left
        anchors.rightMargin: Style.labelSpacing
        width: Math.ceil(numberMetrics.advanceWidth)
        height: parent.height

        Label {
            anchors.right: parent.right
            height: parent.height
            text: root.degrees(root.high)
            size: Style.smallSize
        }
    }

    Item {
        id: low

        anchors.right: rain.left
        anchors.rightMargin: Style.textPadding
        width: Math.ceil(numberMetrics.advanceWidth)
        height: parent.height

        Label {
            anchors.right: parent.right
            height: parent.height
            text: root.degrees(root.low)
            size: Style.smallSize
            color: Theme.dim
        }
    }

    Item {
        id: rain

        anchors.right: parent.right
        width: Math.ceil(numberMetrics.advanceWidth)
        height: parent.height

        Label {
            anchors.right: parent.right
            height: parent.height
            text: root.rain + "%"
            size: Style.smallSize
            color: root.rain >= 30 ? Theme.info : Theme.dim
        }
    }
}

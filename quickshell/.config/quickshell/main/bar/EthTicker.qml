// The ETH price and, unless showChange is off, its 24 h change as plain
// text. The price is green after it went up and red after it went down,
// the change green or red by its sign, and both dim while stale. Hidden until the first price arrives.
import QtQuick
import qs
import qs.components
import qs.services

Row {
    id: root

    property bool showChange: true

    visible: Eth.available
    leftPadding: Style.textPadding - Style.buttonInset
    rightPadding: Style.textPadding - Style.buttonInset
    spacing: 8

    LabelValue {
        label: "ETH"
        value: Eth.priceText
        valueColor: Eth.stale ? Theme.dim
            : Eth.direction > 0 ? Theme.good
            : Eth.direction < 0 ? Theme.bad
            : Theme.foreground
    }

    Label {
        visible: root.showChange && Eth.changeText !== ""
        text: Eth.changeText
        size: Style.labelSize
        capHeight: Style.capHeight
        color: Eth.stale ? Theme.dim : Eth.change24h >= 0 ? Theme.good : Theme.bad
    }
}

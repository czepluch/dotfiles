// One on/off setting, shown as a toggle in the control panel and, while on,
// as a chip in the bar.
import QtQuick

QtObject {
    property string text: ""
    // Chip text in the bar while on; empty for no chip.
    property string chip: ""
    property string chipIcon: ""
    property bool on: false
    property bool available: true

    signal activated()
}

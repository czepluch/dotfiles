// CPU usage, CPU temperature, memory use and battery in one raised panel with
// thin dividers, like the workspaces panel. Numbers are right-aligned in a
// fixed number of digits so nothing shifts. Values turn yellow when high and
// red when critical (temperature, memory pressure, a low battery). The battery reads AC while on mains power. The CPU, TEMP and
// MEM labels each have their own palette color; the battery label stays
// dim. Clicking it opens the system panel.
import QtQuick
import qs
import qs.components
import qs.services

Clickable {
    id: root

    function pad(value, digits) {
        return String(Math.round(value)).padStart(digits, " ");
    }

    implicitWidth: row.implicitWidth + 2 * (Style.textPadding - Style.alertPadding)
    implicitHeight: Style.pillHeight
    cut: Style.panelCut
    baseColor: Theme.glass
    edge: "raised"

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 7

        ReadoutGroup {
            label: "CPU"
            labelColor: Theme.labelHue(Theme.cyan)
            value: root.pad(Stats.cpu * 100, 2) + "%"
            warn: Stats.cpuWarn
        }

        Divider {}

        ReadoutGroup {
            label: "Temp"
            labelColor: Theme.labelHue(Theme.magenta)
            value: root.pad(Stats.temp, 2) + "°C"
            warn: Stats.tempWarn
            alert: Stats.tempAlert
        }

        Divider {}

        ReadoutGroup {
            label: "Mem"
            labelColor: Theme.labelHue(Theme.green)
            value: root.pad(Stats.mem * 100, 2) + "%"
            warn: Stats.memWarn
            alert: Stats.memAlert
        }

        Divider {
            visible: Battery.available
        }

        ReadoutGroup {
            visible: Battery.available
            label: Battery.onAc ? "AC" : "Bat"
            value: root.pad(Battery.percent, 3) + "%"
            warn: Battery.warn
            alert: Battery.low
        }
    }
}

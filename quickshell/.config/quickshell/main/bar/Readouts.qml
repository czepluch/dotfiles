// CPU usage, CPU temperature, memory use and battery in one raised panel with
// thin dividers, like the workspaces panel. Numbers are right-aligned in a
// fixed number of digits so nothing shifts. Temperature and memory invert
// with a hatch when they pass their alert thresholds, and the battery when
// it is low. The battery reads AC while on mains power. Clicking it opens
// the system panel.
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
            value: root.pad(Stats.cpu * 100, 2) + "%"
            warn: Stats.cpuWarn
        }

        Divider {}

        ReadoutGroup {
            label: "Temp"
            value: root.pad(Stats.temp, 2) + "°C"
            warn: Stats.tempWarn
            alert: Stats.tempAlert
        }

        Divider {}

        ReadoutGroup {
            label: "Mem"
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

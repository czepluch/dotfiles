pragma ComponentBehavior: Bound

// The system panel: CPU (with the load of each CPU), temperature, memory,
// swap, disk, network and battery, with graphs of the last 2 minutes for
// CPU and temperature, and the processes using the most CPU. It opens from
// the hardware readouts in the bar; the extra readings run only while it is
// open.
import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

BarPopup {
    id: root

    readonly property int contentWidth: 420
    // Column widths shared by every row.
    readonly property int labelWidth: Math.ceil(labelMetrics.advanceWidth)
    readonly property int valueWidth: Math.ceil(valueMetrics.advanceWidth)
    readonly property int detailWidth: Math.ceil(detailMetrics.advanceWidth)
    readonly property int visualWidth: contentWidth - labelWidth - valueWidth - detailWidth - 3 * Style.textPadding
    readonly property int cpuColumnWidth: Math.ceil(cpuMetrics.advanceWidth)
    readonly property int memColumnWidth: Math.ceil(memMetrics.advanceWidth)
    // Segments of a meter that fills the visual column, and the width of
    // that meter, which the graphs and core bars share.
    readonly property int meterSegments: Math.floor((visualWidth + 2) / 9)
    readonly property int meterWidth: meterSegments * 9 - 2

    function percent(value) {
        return Math.round(value * 100) + "%";
    }

    function gib(bytes) {
        const value = bytes / 1073741824;
        return value >= 100 ? value.toFixed(0) : value.toFixed(1);
    }

    function rate(bytesPerSecond) {
        if (bytesPerSecond < 1000)
            return Math.round(bytesPerSecond) + " B/s";
        if (bytesPerSecond < 1000000)
            return (bytesPerSecond / 1000).toFixed(1) + " kB/s";
        return (bytesPerSecond / 1000000).toFixed(1) + " MB/s";
    }

    function duration(seconds) {
        const minutes = Math.round(seconds / 60);
        return Math.floor(minutes / 60) + ":" + String(minutes % 60).padStart(2, "0");
    }

    function batteryDetail() {
        const device = Battery.device;
        if (Battery.charging)
            return device.timeToFull > 0 ? "charging " + duration(device.timeToFull) : "charging";
        if (Battery.full)
            return "full";
        if (Battery.onAc)
            return "on AC";
        const draw = device.changeRate.toFixed(1) + " W";
        return device.timeToEmpty > 0 ? draw + " · " + duration(device.timeToEmpty) : draw;
    }

    function processMemory(bytes) {
        const mib = bytes / 1048576;
        return mib < 1024 ? Math.round(mib) + "M" : (mib / 1024).toFixed(1) + "G";
    }

    Binding {
        target: Stats
        property: "detailed"
        value: true
        when: root.visible
    }

    TextMetrics {
        id: labelMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.labelSize
        font.letterSpacing: Math.round(0.06 * Style.labelSize * 10) / 10
        text: "SWAP"
    }

    TextMetrics {
        id: valueMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.smallSize
        text: "100°C"
    }

    TextMetrics {
        id: detailMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.smallSize
        text: "18.8 / 30.8 GiB"
    }

    TextMetrics {
        id: cpuMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.smallSize
        text: "999.9%"
    }

    TextMetrics {
        id: memMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.smallSize
        text: "99.9G"
    }

    Column {
        width: root.contentWidth

        SystemRow {
            width: parent.width
            labelWidth: root.labelWidth
            valueWidth: root.valueWidth
            detailWidth: root.detailWidth
            label: "CPU"
            value: root.percent(Stats.cpu)
            detail: "load " + Stats.load.toFixed(2)
            warn: Stats.cpuWarn

            Graph {
                anchors.verticalCenter: parent.verticalCenter
                width: root.meterWidth
                values: Stats.cpuHistory
                warnAt: Stats.cpuWarnLevel
            }
        }

        SystemRow {
            width: parent.width
            labelWidth: root.labelWidth
            valueWidth: root.valueWidth
            detailWidth: root.detailWidth

            CoreBars {
                anchors.verticalCenter: parent.verticalCenter
                width: root.meterWidth
            }
        }

        SystemRow {
            width: parent.width
            labelWidth: root.labelWidth
            valueWidth: root.valueWidth
            detailWidth: root.detailWidth
            label: "Temp"
            value: Math.round(Stats.temp) + "°C"
            detail: Stats.fan >= 0 ? "fan " + Stats.fan + " rpm" : ""
            warn: Stats.tempWarn
            alert: Stats.tempAlert

            Graph {
                anchors.verticalCenter: parent.verticalCenter
                width: root.meterWidth
                values: Stats.tempHistory
                minimum: 30
                maximum: Stats.tempMax
                warnAt: Stats.tempWarnLevel
                alertAt: Stats.tempAlertLevel
            }
        }

        SystemRow {
            width: parent.width
            labelWidth: root.labelWidth
            valueWidth: root.valueWidth
            detailWidth: root.detailWidth
            label: "Mem"
            value: root.percent(Stats.mem)
            detail: root.gib(Stats.memUsed) + " / " + root.gib(Stats.memTotal) + " GiB"
            warn: Stats.memWarn
            alert: Stats.memAlert

            SegMeter {
                anchors.verticalCenter: parent.verticalCenter
                segments: root.meterSegments
                value: Stats.mem
                color: Stats.memAlert ? Theme.bad : Stats.memWarn ? Theme.warn : Theme.accentFill
            }
        }

        SystemRow {
            visible: Stats.swapTotal > 0
            width: parent.width
            labelWidth: root.labelWidth
            valueWidth: root.valueWidth
            detailWidth: root.detailWidth
            label: "Swap"
            value: root.percent(Stats.swapTotal > 0 ? Stats.swapUsed / Stats.swapTotal : 0)
            detail: root.gib(Stats.swapUsed) + " / " + root.gib(Stats.swapTotal) + " GiB"

            SegMeter {
                anchors.verticalCenter: parent.verticalCenter
                segments: root.meterSegments
                value: Stats.swapTotal > 0 ? Stats.swapUsed / Stats.swapTotal : 0
            }
        }

        SystemRow {
            width: parent.width
            labelWidth: root.labelWidth
            valueWidth: root.valueWidth
            detailWidth: root.detailWidth
            label: "Disk"
            value: root.percent(Stats.diskTotal > 0 ? Stats.diskUsed / Stats.diskTotal : 0)
            detail: root.gib(Stats.diskUsed) + " / " + root.gib(Stats.diskTotal) + " GiB"
            warn: Stats.diskWarn

            SegMeter {
                anchors.verticalCenter: parent.verticalCenter
                segments: root.meterSegments
                value: Stats.diskTotal > 0 ? Stats.diskUsed / Stats.diskTotal : 0
                color: Stats.diskWarn ? Theme.warn : Theme.accentFill
            }
        }

        SystemRow {
            width: parent.width
            labelWidth: root.labelWidth
            valueWidth: root.valueWidth
            detailWidth: root.detailWidth
            label: "Net"
            detail: "↑ " + root.rate(Stats.netUp)

            Label {
                height: parent.height
                text: "↓ " + root.rate(Stats.netDown)
                size: Style.smallSize
            }
        }

        SystemRow {
            visible: Battery.available
            width: parent.width
            labelWidth: root.labelWidth
            valueWidth: root.valueWidth
            detailWidth: root.detailWidth
            label: "Bat"
            value: Battery.percent + "%"
            detail: root.batteryDetail()
            warn: Battery.warn
            alert: Battery.low

            SegMeter {
                anchors.verticalCenter: parent.verticalCenter
                segments: root.meterSegments
                value: Battery.percent / 100
                color: Battery.low ? Theme.bad : Battery.warn ? Theme.warn : Theme.accentFill
            }
        }
    }

    Rectangle {
        width: root.contentWidth
        height: 1
        color: Theme.divider
    }

    Column {
        width: root.contentWidth

        // Heading with the column names over the numbers.
        Item {
            width: parent.width
            height: Style.sectionHeight

            SectionLabel {
                text: "Top processes"
            }

            Label {
                anchors.right: parent.right
                anchors.rightMargin: root.memColumnWidth + Style.textPadding
                height: parent.height
                text: "CPU"
                caps: true
            }

            Label {
                anchors.right: parent.right
                height: parent.height
                text: "Mem"
                caps: true
            }
        }

        Repeater {
            model: Stats.processes

            Item {
                id: processRow

                required property var modelData

                width: root.contentWidth
                height: Style.rowHeight

                Label {
                    height: parent.height
                    text: processRow.modelData.name
                    size: Style.smallSize
                    maxWidth: parent.width - root.cpuColumnWidth - root.memColumnWidth - 3 * Style.textPadding
                }

                Label {
                    anchors.right: parent.right
                    anchors.rightMargin: root.memColumnWidth + Style.textPadding
                    height: parent.height
                    text: processRow.modelData.cpu.toFixed(1) + "%"
                    size: Style.smallSize
                    color: Theme.dim
                }

                Label {
                    anchors.right: parent.right
                    height: parent.height
                    text: root.processMemory(processRow.modelData.mem)
                    size: Style.smallSize
                    color: Theme.dim
                }
            }
        }
    }

    ToggleButton {
        width: root.contentWidth
        text: "Open btop"
        onClicked: {
            Quickshell.execDetached(["ghostty", "-e", "btop"]);
            root.visible = false;
        }
    }
}

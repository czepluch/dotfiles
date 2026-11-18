pragma Singleton

// Laptop battery state from UPower, shared by the bar and the lock screen.
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool available: device.ready && device.isLaptopBattery
    readonly property int percent: Math.round(device.percentage * 100)
    readonly property bool charging: device.state === UPowerDeviceState.Charging
    readonly property bool full: device.state === UPowerDeviceState.FullyCharged
    readonly property bool low: available && percent <= 15 && !charging
    // Getting low: shown in the warning color.
    readonly property bool warn: available && percent <= 30 && !charging
    // Running on mains power (charging, full or held at a charge limit).
    readonly property bool onAc: !UPower.onBattery

    readonly property var levelIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property string icon: charging ? "󰂄"
        : full ? "󰚥"
        : levelIcons[Math.min(10, Math.floor(percent / 10))]
}

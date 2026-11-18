pragma Singleton

// The control panel's toggles in display order, also used for the bar's
// chips.
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.services

Singleton {
    readonly property list<ToggleItem> items: [
        ToggleItem {
            text: "Do not disturb"
            chip: "DND"
            on: Toggles.dnd
            onActivated: Toggles.toggleDnd()
        },
        ToggleItem {
            text: "Keep awake"
            chip: "Awake"
            on: Session.keepAwake
            onActivated: Session.keepAwake = !Session.keepAwake
        },
        ToggleItem {
            text: "Mic muted"
            chip: "Mic"
            chipIcon: "󰍭"
            on: Audio.micMuted
            onActivated: Audio.toggleMic()
        },
        ToggleItem {
            text: "VPN"
            chip: "VPN"
            on: Toggles.vpn
            onActivated: Toggles.toggleVpn()
        },
        ToggleItem {
            text: "Night light"
            on: Toggles.nightLight
            onActivated: Toggles.toggleNightLight()
        },
        ToggleItem {
            text: "Bluetooth"
            available: Bluetooth.defaultAdapter !== null
            on: Bluetooth.defaultAdapter?.enabled ?? false
            onActivated: Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
        }
    ]
}

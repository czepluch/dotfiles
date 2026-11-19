pragma Singleton

// The control panel's toggles in display order, also used for the bar's
// chips.
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs
import qs.services

Singleton {
    readonly property list<ToggleItem> items: [
        ToggleItem {
            text: "Do not disturb"
            chip: "DND"
            chipColor: Theme.warn
            on: Notifications.dnd
            onActivated: Notifications.dnd = !Notifications.dnd
        },
        ToggleItem {
            text: "Keep awake"
            chip: "Awake"
            chipColor: Theme.info
            on: Session.keepAwake
            onActivated: Session.keepAwake = !Session.keepAwake
        },
        ToggleItem {
            text: "Mic muted"
            chip: "Mic"
            chipIcon: "󰍭"
            chipColor: Theme.bad
            on: Audio.micMuted
            onActivated: Audio.toggleMic()
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

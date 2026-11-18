pragma Singleton

// Network state from NetworkManager: the wired link, the Wi-Fi device, the
// connected Wi-Fi network and the networks in range.
import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property list<NetworkDevice> devices: Networking.devices.values
    readonly property NetworkDevice wired: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property WifiDevice wifi: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property WifiNetwork wifiNetwork: wifi?.networks.values.find(n => n.connected) ?? null

    // Wi-Fi networks in range: the connected one first, then by signal strength.
    readonly property var networks: (wifi?.networks.values ?? []).slice()
        .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))

    readonly property bool connected: wired !== null || wifiNetwork !== null
    readonly property var wifiIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
    readonly property string icon: wired ? "󰈀"
        : wifiNetwork ? signalIcon(wifiNetwork.signalStrength)
        : "󰤭"

    function signalIcon(strength) {
        return wifiIcons[Math.min(4, Math.floor(strength * 5))];
    }
}

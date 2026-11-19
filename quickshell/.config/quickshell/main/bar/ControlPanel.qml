pragma ComponentBehavior: Bound

// The control panel: power mode, Wi-Fi networks, volume, brightness, the
// toggles from ToggleList, and a power icon that opens the session menu
// (see Launcher). It opens from the control icons, flush with the right end
// of the bar. Wi-Fi scanning runs only while it is open.
import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

BarPopup {
    id: root

    readonly property int contentWidth: 420

    // Width of a button when n buttons share a row.
    function cellWidth(n) {
        return Math.floor((contentWidth - (n - 1) * Style.gap) / n);
    }

    alignRight: true
    spacing: 10

    onVisibleChanged: {
        if (visible) {
            Toggles.refresh();
            Brightness.refresh();
        }
    }

    // Active only while open, so a closed panel on another screen does not
    // turn the scanner off.
    Binding {
        when: Network.wifi !== null && root.visible
        target: Network.wifi
        property: "scannerEnabled"
        value: true
    }

    SectionLabel {
        text: "Power mode"
    }

    Row {
        spacing: Style.gap

        Repeater {
            model: Power.profiles

            ToggleButton {
                required property int modelData

                width: root.cellWidth(Power.profiles.length)
                text: Power.iconFor(modelData) + " " + Power.nameFor(modelData)
                checked: Power.profile === modelData
                onClicked: Power.set(modelData)
            }
        }
    }

    SectionLabel {
        text: "Wi-Fi"
    }

    Column {
        width: root.contentWidth
        spacing: 2

        Repeater {
            model: ScriptModel {
                values: Network.networks.slice(0, 6)
            }

            Clickable {
                id: networkRow

                required property var modelData
                readonly property bool canConnect: !modelData.connected && modelData.known

                width: root.contentWidth
                height: Style.rowHeight
                enabled: canConnect || modelData.connected
                baseColor: modelData.connected ? Theme.glass : "transparent"
                onClicked: {
                    if (networkRow.canConnect)
                        networkRow.modelData.connect();
                }

                Row {
                    x: Style.textPadding
                    height: networkRow.height
                    spacing: Style.textPadding

                    Label {
                        height: networkRow.height
                        text: Network.signalIcon(networkRow.modelData.signalStrength)
                        size: Style.smallSize
                        color: networkRow.modelData.known ? Theme.foreground : Theme.dim
                    }

                    Label {
                        height: networkRow.height
                        text: networkRow.modelData.name
                        size: Style.smallSize
                        color: networkRow.modelData.known ? Theme.foreground : Theme.dim
                    }
                }

                Label {
                    anchors.right: networkRow.right
                    anchors.rightMargin: Style.textPadding
                    height: networkRow.height
                    visible: networkRow.modelData.connected
                    text: "Connected"
                    caps: true
                    capHeight: Style.smallCap
                }
            }
        }

        Label {
            visible: Network.networks.length === 0
            height: Style.rowHeight
            text: Network.wifi ? "Searching for networks…" : "No Wi-Fi device"
            size: Style.smallSize
            color: Theme.dim
        }
    }

    SectionLabel {
        text: "Volume · " + (Audio.muted ? "muted" : Audio.percent + "%")
    }

    Slider {
        width: root.contentWidth
        value: Audio.muted ? 0 : Audio.volume
        onMoved: v => Audio.setVolume(v)
    }

    SectionLabel {
        visible: Brightness.available
        text: "Brightness · " + Math.round(Brightness.value * 100) + "%"
    }

    Slider {
        visible: Brightness.available
        width: root.contentWidth
        value: Brightness.value
        onMoved: v => Brightness.set(v)
    }

    Grid {
        topPadding: 2
        columns: 3
        spacing: Style.gap

        Repeater {
            model: ToggleList.items

            ToggleButton {
                required property ToggleItem modelData

                width: root.cellWidth(3)
                enabled: modelData.available
                text: modelData.text
                checked: modelData.on
                onClicked: modelData.activated()
            }
        }
    }

    Item {
        width: root.contentWidth
        height: Style.buttonSize

        IconButton {
            anchors.right: parent.right
            icon: "󰐥"
            iconColor: Theme.dim
            onClicked: {
                Launcher.open("session");
                root.visible = false;
            }
        }
    }
}

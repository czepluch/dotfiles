// The short message from Osd, as a row under the clock: the volume or the
// brightness with a meter, the keyboard layout, do-not-disturb switched on
// or off, or the last seconds before the idle lock, inverted. A new message
// slides in.
import QtQuick
import qs
import qs.components
import qs.services

Item {
    id: root

    implicitWidth: Style.messageWidth
    implicitHeight: Style.pillHeight

    HubView {
        anchors.fill: parent
        shown: Osd.message === "volume"

        Label {
            text: Audio.icon
        }

        Item {
            implicitWidth: volumeMeter.width
            implicitHeight: Style.pillHeight

            SegMeter {
                id: volumeMeter

                anchors.verticalCenter: parent.verticalCenter
                segments: 10
                value: Audio.muted ? 0 : Audio.volume
            }
        }

        Label {
            text: Audio.muted ? "MUTED" : String(Audio.percent).padStart(3, " ")
        }
    }

    HubView {
        anchors.fill: parent
        shown: Osd.message === "brightness"

        Label {
            text: Brightness.value < 0.34 ? "󰃞" : Brightness.value < 0.67 ? "󰃟" : "󰃠"
        }

        Item {
            implicitWidth: brightnessMeter.width
            implicitHeight: Style.pillHeight

            SegMeter {
                id: brightnessMeter

                anchors.verticalCenter: parent.verticalCenter
                segments: 10
                value: Brightness.value
            }
        }

        Label {
            text: String(Math.round(Brightness.value * 100)).padStart(3, " ")
        }
    }

    HubView {
        anchors.fill: parent
        shown: Osd.message === "layout"

        Chip {
            text: Keyboard.layout
            fill: Theme.accentFill
        }

        Label {
            text: Keyboard.shortName
        }
    }

    HubView {
        anchors.fill: parent
        shown: Osd.message === "dnd"

        Label {
            text: Notifications.dnd ? "󰂛" : "󰂚"
        }

        Label {
            text: "Do not disturb"
            caps: true
            capHeight: Style.capHeight
        }

        Label {
            text: Notifications.dnd ? "ON" : "OFF"
            bold: true
        }
    }

    HubView {
        anchors.fill: parent
        shown: Osd.message === "lock"

        RoundRect {
            anchors.fill: parent
            anchors.topMargin: Style.buttonInset
            anchors.bottomMargin: Style.buttonInset
            radius: Style.cellRadius
            color: Theme.foreground
        }
    }

    HubView {
        anchors.fill: parent
        shown: Osd.message === "lock"

        Label {
            text: "󰌾"
            color: Theme.background
        }

        Label {
            text: "Locking in"
            caps: true
            capHeight: Style.capHeight
            color: Theme.background
        }

        Label {
            text: Osd.lockRemaining
            bold: true
            color: Theme.background
        }
    }
}

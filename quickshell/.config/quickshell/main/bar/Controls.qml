// The control icons at the right end of the bar: power mode, Wi-Fi and
// volume, with the volume level next to its icon. Clicking any of them
// opens the control panel. Scrolling on volume changes it; middle-clicking
// mutes. Power mode is green in saver, yellow in balanced and red in
// performance mode. Wi-Fi dims while disconnected and volume is red while
// muted.
import QtQuick
import qs
import qs.components
import qs.services

CutRect {
    id: root

    signal openPanel()

    implicitWidth: row.implicitWidth + 2 * Style.buttonInset
    implicitHeight: Style.pillHeight
    color: Theme.glass
    edge: "raised"

    Row {
        id: row

        anchors.centerIn: parent
        spacing: Style.buttonInset

        IconButton {
            icon: Power.icon
            iconColor: Power.saver ? Theme.good : Power.performance ? Theme.bad : Theme.warn
            onClicked: root.openPanel()
        }

        IconButton {
            icon: Network.icon
            iconColor: Network.connected ? Theme.foreground : Theme.dim
            onClicked: root.openPanel()
        }

        IconButton {
            icon: Audio.icon
            iconColor: Audio.muted ? Theme.bad : Theme.foreground
            // Padded to three digits so the bar does not shift.
            text: String(Audio.percent).padStart(3, " ") + "%"
            textColor: Audio.muted ? Theme.dim : Theme.foreground
            wheelEnabled: true
            onClicked: mouse => {
                if (mouse.button === Qt.MiddleButton)
                    Audio.toggleMute();
                else
                    root.openPanel();
            }
            onStepped: direction => Audio.changeVolume(direction * Style.wheelValueStep)
        }
    }
}

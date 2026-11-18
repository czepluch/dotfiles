// The control icons at the right end of the bar: power mode, Wi-Fi and
// volume. Clicking any of them opens the control panel. Scrolling on volume
// changes it; middle-clicking mutes.
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
            onClicked: root.openPanel()
        }

        IconButton {
            icon: Network.icon
            onClicked: root.openPanel()
        }

        IconButton {
            icon: Audio.icon
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

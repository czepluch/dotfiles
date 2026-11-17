// Lock screen UI for one monitor: a translucent card with clock, date,
// password field and a status row (keyboard layout, Caps Lock, ETH price,
// battery). The area around the card is transparent so the compositor's
// blurred desktop shows through.
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs

Item {
    id: root

    required property LockContext context

    // Multiplies every size on the card.
    readonly property real uiScale: 1.25
    readonly property real margin: 36 * uiScale

    property date now: new Date()

    readonly property var battery: UPower.displayDevice
    readonly property int batteryPercent: Math.round(battery.percentage * 100)
    readonly property bool batteryCharging: battery.state === UPowerDeviceState.Charging
    readonly property bool batteryFull: battery.state === UPowerDeviceState.FullyCharged
    readonly property var batteryIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    // Fires just after each full second so the seconds never skip.
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.now = new Date();
            interval = 1000 - root.now.getMilliseconds() + 10;
        }
    }

    // Hides the desktop until Hyprland's blur has been raised.
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        opacity: root.context.blurReady ? 0 : 1

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    Rectangle {
        id: card

        anchors.centerIn: parent
        width: Math.max(440 * root.uiScale, content.implicitWidth + 2 * root.margin)
        height: content.implicitHeight + 2 * root.margin
        radius: 18 * root.uiScale
        color: Qt.alpha(Theme.background, 0.55)
        border.width: 1
        border.color: Qt.alpha(Theme.foreground, 0.12)

        transform: Translate {
            id: shake
        }

        SequentialAnimation {
            id: shakeAnimation

            NumberAnimation { target: shake; property: "x"; to: -12; duration: 50 }
            NumberAnimation { target: shake; property: "x"; to: 12; duration: 70 }
            NumberAnimation { target: shake; property: "x"; to: -8; duration: 60 }
            NumberAnimation { target: shake; property: "x"; to: 0; duration: 50 }
        }

        Connections {
            target: root.context

            function onFailed() {
                shakeAnimation.restart();
            }
        }

        ColumnLayout {
            id: content

            anchors {
                fill: parent
                margins: root.margin
            }
            spacing: 0

            Text {
                text: Qt.formatTime(root.now, "HH:mm:ss")
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 88 * root.uiScale
                font.weight: Font.Light
                renderType: Text.NativeRendering
            }

            Text {
                Layout.topMargin: -2 * root.uiScale
                text: root.now.toLocaleDateString(Qt.locale("en_GB"), "dddd d MMMM yyyy")
                color: Qt.alpha(Theme.foreground, 0.65)
                font.family: Theme.fontFamily
                font.pixelSize: 17 * root.uiScale
            }

            Rectangle {
                id: field

                Layout.fillWidth: true
                Layout.topMargin: 32 * root.uiScale
                implicitHeight: 46 * root.uiScale
                radius: 12 * root.uiScale
                color: Qt.alpha(Theme.background, 0.6)
                border.width: 1.5
                border.color: root.context.showFailure ? Theme.red
                    : input.activeFocus ? Qt.alpha(Theme.accent, 0.9)
                    : Qt.alpha(Theme.foreground, 0.15)

                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }

                TextInput {
                    id: input

                    anchors {
                        fill: parent
                        leftMargin: 16 * root.uiScale
                        rightMargin: 16 * root.uiScale
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    focus: true
                    enabled: !root.context.unlockInProgress
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    inputMethodHints: Qt.ImhSensitiveData
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 18 * root.uiScale
                    font.letterSpacing: 2 * root.uiScale

                    onTextChanged: root.context.currentText = text
                    onAccepted: root.context.tryUnlock()
                    Keys.onPressed: root.context.refreshKeyboard()

                    // Keeps the field in sync across monitors.
                    Connections {
                        target: root.context

                        function onCurrentTextChanged() {
                            input.text = root.context.currentText;
                        }
                    }
                }

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 16 * root.uiScale
                        verticalCenter: parent.verticalCenter
                    }
                    visible: input.text.length === 0
                    text: root.context.unlockInProgress ? "Checking…"
                        : root.context.showFailure ? root.context.failureText
                        : "Password"
                    color: root.context.showFailure ? Theme.red : Qt.alpha(Theme.foreground, 0.4)
                    font.family: Theme.fontFamily
                    font.pixelSize: 15 * root.uiScale
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 18 * root.uiScale
                spacing: 14 * root.uiScale

                Text {
                    text: root.context.layout
                    color: Qt.alpha(Theme.foreground, 0.65)
                    font.family: Theme.fontFamily
                    font.pixelSize: 14 * root.uiScale
                }

                Text {
                    visible: root.context.capsLock
                    text: "Caps Lock"
                    color: Theme.yellow
                    font.family: Theme.fontFamily
                    font.pixelSize: 14 * root.uiScale
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    visible: !isNaN(root.context.ethPrice)
                    text: "󰡪 $" + root.context.ethPrice.toLocaleString(Qt.locale("en_US"), "f", 0)
                    color: Qt.alpha(Theme.foreground, 0.65)
                    font.family: Theme.fontFamily
                    font.pixelSize: 14 * root.uiScale
                }

                Text {
                    visible: root.battery.ready && root.battery.isLaptopBattery
                    text: (root.batteryCharging ? "󰂄" : root.batteryFull ? "󰚥"
                        : root.batteryIcons[Math.min(10, Math.floor(root.batteryPercent / 10))])
                        + " " + root.batteryPercent + "%"
                    color: root.batteryPercent <= 15 && !root.batteryCharging ? Theme.red
                        : Qt.alpha(Theme.foreground, 0.65)
                    font.family: Theme.fontFamily
                    font.pixelSize: 14 * root.uiScale
                }
            }
        }
    }
}

// Lock screen UI for one monitor: a translucent card with clock, date,
// password field and a status row (keyboard layout, Caps Lock, ETH price,
// battery). The area around the card is transparent so the compositor's
// blurred desktop shows through.
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components
import qs.services

Item {
    id: root

    required property LockContext context

    // Multiplies every size on the card.
    readonly property real uiScale: 1.25
    readonly property real margin: 36 * uiScale

    readonly property date now: clock.date

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }

    Connections {
        target: Session

        function onResumed() {
            clock.enabled = false;
            clock.enabled = true;
        }
    }

    // Hides the desktop until Hyprland's blur has been raised.
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        opacity: root.context.blurReady ? 0 : 1

        Behavior on opacity {
            NumberAnimation { duration: Style.reduceMotion ? 0 : 250 }
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
                if (!Style.reduceMotion)
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
                    ColorAnimation { duration: Style.change }
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
                    Keys.onPressed: Keyboard.refresh()

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
                    text: Keyboard.layout
                    color: Qt.alpha(Theme.foreground, 0.65)
                    font.family: Theme.fontFamily
                    font.pixelSize: 14 * root.uiScale
                }

                Chip {
                    visible: Keyboard.capsLock
                    text: "Caps Lock"
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    visible: Eth.available
                    text: "󰡪 " + Eth.priceText
                    color: Qt.alpha(Theme.foreground, 0.65)
                    font.family: Theme.fontFamily
                    font.pixelSize: 14 * root.uiScale
                }

                // Inverted with the alert hatch while the battery is low.
                Item {
                    visible: Battery.available
                    implicitWidth: batteryText.implicitWidth
                    implicitHeight: batteryText.implicitHeight

                    CutRect {
                        visible: Battery.low
                        anchors.fill: parent
                        anchors.margins: -Style.buttonInset
                        cut: Style.cellCut
                        color: Theme.foreground
                        hatch: true
                    }

                    Text {
                        id: batteryText

                        text: Battery.icon + " " + Battery.percent + "%"
                        color: Battery.low ? Theme.background : Qt.alpha(Theme.foreground, 0.65)
                        font.family: Theme.fontFamily
                        font.pixelSize: 14 * root.uiScale
                    }
                }
            }
        }
    }
}

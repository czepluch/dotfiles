pragma ComponentBehavior: Bound

// Lock screen for one monitor, in the bar's style: the bar in its locked
// form along the top, and the hub's time display grown into a large display
// in the middle, with the password slot and the keyboard state below it.
// Once the blur is up, the display grows out of the hub's place in the bar;
// after a correct password it shrinks back before the lock is released. The
// area around it is transparent, so the compositor's blurred desktop shows
// through.
import QtQuick
import Quickshell
import qs
import qs.bar
import qs.components
import qs.services

Item {
    id: root

    required property LockContext context
    required property ShellScreen screen

    readonly property bool open: context.blurReady && !context.unlocking
    // 0 while the display sits in the hub, 1 once it has grown.
    property real progress: open ? 1 : 0
    readonly property rect hubRect: bar.hubRect
    readonly property int displayWidth: Math.ceil(timeMetrics.advanceWidth) + 2 * Style.lockPadding
    readonly property int displayHeight: 2 * Style.lockPadding + Style.lockTimeCap + Style.lockGap + Style.lockTextCap
    // The display, the slot and the status row, centered on the screen.
    readonly property int blockHeight: displayHeight + Style.lockGap + Style.lockFieldHeight + Style.lockGap + Style.pillHeight
    readonly property rect displayRect: Qt.rect(Math.round((width - displayWidth) / 2),
        Math.round((height - blockHeight) / 2), displayWidth, displayHeight)
    // Where the time sits in the hub: first in a centered row with a divider
    // and the date.
    readonly property real hubTimeX: hubRect.x + Math.round((hubRect.width - smallTimeMetrics.advanceWidth - 2 * Style.popupSpacing - 1 - hubDate.implicitWidth) / 2)

    function mix(from, to) {
        return from + (to - from) * progress;
    }

    Behavior on progress {
        NumberAnimation {
            duration: root.open ? Style.lockGrow : Style.lockShrink
            easing.type: Easing.OutCubic
        }
    }

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

    Connections {
        target: root.context

        function onCurrentTextChanged() {
            input.text = root.context.currentText;
        }
    }

    TextMetrics {
        id: timeMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.lockTimeSize
        font.bold: true
        text: "00:00:00"
    }

    TextMetrics {
        id: smallTimeMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Style.size
        font.bold: true
        text: "00:00:00"
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

    BarContent {
        id: bar

        width: parent.width
        height: Style.height + Style.screenMargin
        window: null
        screen: root.screen
        locked: true
    }

    // The hub's display, growing into the lock display: the hub's glass, over
    // the bar while in it and over the blurred desktop once grown.
    RoundRect {
        id: display

        x: Math.round(root.mix(root.hubRect.x, root.displayRect.x))
        y: Math.round(root.mix(root.hubRect.y, root.displayRect.y))
        width: Math.round(root.mix(root.hubRect.width, root.displayRect.width))
        height: Math.round(root.mix(root.hubRect.height, root.displayRect.height))
        radius: Math.round(root.mix(Style.panelRadius, Style.surfaceRadius))
        color: Theme.glass
        edge: "sunken"
    }

    // The hub's divider and date, fading out as the display leaves the bar.
    Divider {
        x: root.hubTimeX + Math.ceil(smallTimeMetrics.advanceWidth) + Style.popupSpacing
        y: root.hubRect.y
        opacity: hubDate.opacity
    }

    Label {
        id: hubDate

        x: root.hubTimeX + Math.ceil(smallTimeMetrics.advanceWidth) + 2 * Style.popupSpacing + 1
        y: root.hubRect.y
        height: root.hubRect.height
        opacity: Math.max(0, 1 - 4 * root.progress)
        text: Qt.formatDate(clock.date, "ddd d MMM")
    }

    // The time, drawn at the large size and scaled down to the hub's size
    // while in the bar, so it is sharp once grown.
    Label {
        readonly property real centerX: root.mix(root.hubTimeX + smallTimeMetrics.advanceWidth / 2, root.displayRect.x + root.displayRect.width / 2)
        readonly property real centerY: root.mix(root.hubRect.y + root.hubRect.height / 2, root.displayRect.y + Style.lockPadding + Style.lockTimeCap / 2)

        x: Math.round(centerX - width / 2)
        y: Math.round(centerY - height / 2)
        height: Style.lockTimeCap
        scale: root.mix(Style.size / Style.lockTimeSize, 1)
        text: Qt.formatTime(clock.date, "HH:mm:ss")
        size: Style.lockTimeSize
        bold: true
        color: Theme.accentFill
    }

    Label {
        anchors.horizontalCenter: display.horizontalCenter
        y: display.y + display.height - Style.lockPadding - Style.lockTextCap
        height: Style.lockTextCap
        opacity: Math.max(0, (root.progress - 0.6) / 0.4)
        text: clock.date.toLocaleDateString(Qt.locale("en_GB"), "dddd d MMMM yyyy")
        caps: true
        size: Style.lockTextSize
        color: Theme.dim
    }

    // The password slot and the keyboard state, fading in once the display
    // has grown and out first when it shrinks back.
    Item {
        anchors.fill: parent
        opacity: root.open ? 1 : 0

        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation {
                    duration: root.open ? Style.lockLateDelay : 0
                }

                NumberAnimation {
                    duration: Style.reduceMotion ? 0 : root.open ? 300 : 120
                }
            }
        }

        RoundRect {
            id: slot

            readonly property bool failed: root.context.showFailure

            // Wide enough for lockMinDots dots and the cursor; longer passwords
            // show their last maxDots dots.
            readonly property int cursorWidth: Math.round(Style.lockTextSize * 0.55)
            readonly property int maxDots: Math.max(0, Math.floor((width - Style.lockPadding - cursorWidth) / (Style.lockDotSize + Style.lockDotGap)))

            x: Math.round((root.width - width) / 2)
            y: root.displayRect.y + root.displayRect.height + Style.lockGap
            width: Math.max(Style.lockFieldWidth,
                Style.lockPadding + Style.lockMinDots * (Style.lockDotSize + Style.lockDotGap) + cursorWidth)
            height: Style.lockFieldHeight
            radius: Style.panelRadius
            color: failed ? Theme.bad : "transparent"

            RoundRect {
                visible: !slot.failed
                anchors.fill: parent
                radius: parent.radius
                color: Theme.glass
                outline: input.activeFocus ? Theme.accentFill : Theme.outline
                edge: "sunken"
            }

            // Takes the keystrokes; the slot shows dots and a block cursor instead.
            TextInput {
                id: input

                width: 1
                height: 1
                opacity: 0
                focus: true
                enabled: !root.context.unlockInProgress && !root.context.unlocking
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                onTextChanged: root.context.currentText = text
                onAccepted: root.context.tryUnlock()
                Keys.onPressed: Keyboard.refresh()
            }

            Row {
                x: Style.lockPadding / 2
                height: parent.height
                spacing: Style.labelSpacing

                Row {
                    visible: root.context.currentText.length > 0 && !slot.failed
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.lockDotGap

                    Repeater {
                        model: Math.min(root.context.currentText.length, slot.maxDots)

                        Rectangle {
                            width: Style.lockDotSize
                            height: Style.lockDotSize
                            radius: Style.lockDotSize / 2
                            color: Theme.foreground
                        }
                    }
                }

                // A block cursor that does not blink.
                Item {
                    visible: input.activeFocus && input.enabled && !slot.failed
                    width: slot.cursorWidth
                    height: parent.height

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: Style.lockTextCap + 8
                        color: Theme.accentFill
                    }
                }

                Label {
                    visible: root.context.currentText.length === 0 || slot.failed
                    height: parent.height
                    text: slot.failed ? root.context.failureText
                        : root.context.unlockInProgress ? "Checking…"
                        : "Password"
                    caps: true
                    size: Style.lockTextSize
                    color: slot.failed ? Theme.textOn(Theme.bad) : Theme.dim
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            y: slot.y + slot.height + Style.lockGap
            spacing: Style.textPadding

            Chip {
                text: Keyboard.layout
                fill: Theme.accentFill
            }

            Label {
                text: Keyboard.shortName
                color: Theme.dim
            }

            Chip {
                visible: Keyboard.capsLock
                text: "Caps Lock"
                fill: Theme.warn
            }
        }
    }
}

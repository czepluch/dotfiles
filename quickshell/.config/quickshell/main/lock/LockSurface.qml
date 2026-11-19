pragma ComponentBehavior: Bound

// Lock screen for one monitor, in the style of the bar and the launcher:
// the bar in its locked form along the top, and a panel in the middle with
// the time, the date, the password field and the keyboard state. Once the
// blur is up, the panel grows out of the clock's place in the bar; after a
// correct password it shrinks back before the lock is released. The area
// around it is transparent, so the compositor's blurred desktop shows
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
    // 0 while the panel sits in the hub, 1 once it has grown.
    property real progress: open ? 1 : 0
    readonly property rect hubRect: bar.hubRect
    // The password field is wide enough for lockMinDots dots and the cursor;
    // longer passwords show their last dots.
    readonly property int cursorWidth: Math.round(Style.lockTextSize * 0.55)
    readonly property int fieldWidth: Math.max(Style.lockFieldWidth,
        Style.lockPadding + Style.lockMinDots * (Style.lockDotSize + Style.lockDotGap) + cursorWidth)
    // The panel, centered on the screen: the time, the date, the password
    // field and the keyboard state, each a gap apart.
    readonly property int panelWidth: Math.max(Math.ceil(timeMetrics.advanceWidth), fieldWidth) + 2 * Style.lockPadding
    readonly property int panelHeight: 2 * Style.lockPadding + Style.lockTimeCap + Style.lockGap + Style.lockTextCap
        + Style.lockGap + Style.lockFieldHeight + Style.lockGap + Style.pillHeight
    readonly property rect panelRect: Qt.rect(Math.round((width - panelWidth) / 2),
        Math.round((height - panelHeight) / 2), panelWidth, panelHeight)
    // The top of the date, the password field and the keyboard state.
    readonly property int dateTop: panelRect.y + Style.lockPadding + Style.lockTimeCap + Style.lockGap
    readonly property int fieldTop: dateTop + Style.lockTextCap + Style.lockGap
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

    // The panel, growing out of the clock's place in the bar and fading in
    // as it grows.
    RoundRect {
        id: panel

        x: Math.round(root.mix(root.hubRect.x, root.panelRect.x))
        y: Math.round(root.mix(root.hubRect.y, root.panelRect.y))
        width: Math.round(root.mix(root.hubRect.width, root.panelRect.width))
        height: Math.round(root.mix(root.hubRect.height, root.panelRect.height))
        radius: Math.round(root.mix(Style.panelRadius, Style.surfaceRadius))
        opacity: root.progress
        color: Theme.barFill
        outline: Theme.outline
        edge: "raised"
    }

    // The hub's divider and date, fading out as the panel leaves the bar.
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
        readonly property real centerX: root.mix(root.hubTimeX + smallTimeMetrics.advanceWidth / 2, root.panelRect.x + root.panelRect.width / 2)
        readonly property real centerY: root.mix(root.hubRect.y + root.hubRect.height / 2, root.panelRect.y + Style.lockPadding + Style.lockTimeCap / 2)

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
        anchors.horizontalCenter: panel.horizontalCenter
        // Moves with the panel while it grows.
        y: Math.round(root.mix(root.hubRect.y, root.dateTop))
        height: Style.lockTextCap
        opacity: Math.max(0, (root.progress - 0.6) / 0.4)
        text: clock.date.toLocaleDateString(Qt.locale("en_GB"), "dddd d MMMM yyyy")
        caps: true
        size: Style.lockTextSize
        color: Theme.dim
    }

    // The password field and the keyboard state, fading in once the panel
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

            // How many dots fit; longer passwords show their last ones.
            readonly property int maxDots: Math.max(0, Math.floor((width - Style.lockPadding - root.cursorWidth) / (Style.lockDotSize + Style.lockDotGap)))

            x: root.panelRect.x + Style.lockPadding
            y: root.fieldTop
            width: root.panelRect.width - 2 * Style.lockPadding
            height: Style.lockFieldHeight
            radius: Style.panelRadius
            color: failed ? Theme.bad : "transparent"

            RoundRect {
                visible: !slot.failed
                anchors.fill: parent
                radius: parent.radius
                color: Theme.glass
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
                    width: root.cursorWidth
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

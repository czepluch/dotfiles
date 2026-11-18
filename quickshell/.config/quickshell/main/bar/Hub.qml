pragma ComponentBehavior: Bound

// The center of the bar: one sunken display with the ETH price, the time and
// the current Hacker News headline, separated by thin dividers. The time stays
// in the middle of the screen while there is room. Short messages from Osd
// (volume, layout, the idle lock countdown) replace the time. Where the space
// right of the time is too narrow for the headline, the headline gets its own
// display after the workspaces. Clicking the time opens the dashboard;
// clicking the headline opens the story, right-clicking it opens the
// discussion. The ETH price dims while it is stale.
import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

Item {
    id: root

    // Free horizontal space in this item's coordinates: right of the left
    // group and left of the right group.
    property real leftLimit: 0
    property real rightLimit: width
    // The time part, for anchoring the dashboard.
    readonly property Item timeItem: timeSegment
    readonly property int pad: Style.textPadding
    readonly property int gap: Style.buttonInset
    readonly property int timeWidth: 220
    readonly property int minHeadlineWidth: 260
    readonly property int ethWidth: Math.ceil(ethRow.implicitWidth) + 2 * pad
    // Places the time in the middle, moved left when the right group needs the room.
    readonly property real displayX: {
        const centered = Math.round(width / 2 - timeWidth / 2) - 1 - ethWidth;
        const room = rightLimit - gap - (ethWidth + 1 + timeWidth);
        return Math.max(leftLimit + gap, Math.min(centered, room));
    }
    readonly property real timeRight: displayX + ethWidth + 1 + timeWidth
    // Room for the headline right of the time, inside the display.
    readonly property real rightRoom: rightLimit - gap - timeRight - 1
    readonly property bool headlineInDisplay: rightRoom >= minHeadlineWidth
    // Room for the headline's own display left of the hub display.
    readonly property real leftRoom: displayX - gap - (leftLimit + gap)
    readonly property int headlineNatural: Math.ceil(hnLabelMetrics.advanceWidth + Style.labelSpacing + titleMetrics.advanceWidth) + 2 * pad
    readonly property real headlineWidth: Math.min(headlineNatural, headlineInDisplay ? rightRoom : leftRoom)

    signal openDashboard()

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Connections {
        target: Session

        function onResumed() {
            clock.enabled = false;
            clock.enabled = true;
        }
    }

    TextMetrics {
        id: hnLabelMetrics

        text: "HN"
        font.family: Theme.fontFamily
        font.pixelSize: Style.labelSize
        font.capitalization: Font.AllUppercase
        font.letterSpacing: Math.round(0.06 * Style.labelSize * 10) / 10
    }

    TextMetrics {
        id: titleMetrics

        text: HackerNews.current?.title ?? ""
        font.family: Theme.fontFamily
        font.pixelSize: Style.size
    }

    // The hub display: ETH | time | headline.
    CutRect {
        x: root.displayX
        width: root.ethWidth + 1 + root.timeWidth + (root.headlineInDisplay ? 1 + root.headlineWidth : 0)
        height: Style.pillHeight
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.glass
        edge: "sunken"

        Row {
            id: ethRow

            x: root.pad
            spacing: 8

            LabelValue {
                label: "ETH"
                value: Eth.priceText
                valueColor: Eth.stale ? Theme.dim : Theme.foreground
            }

            Label {
                visible: Eth.changeText !== ""
                text: Eth.changeText
                size: Style.labelSize
                capHeight: Style.capHeight
                color: Theme.dim
            }
        }

        Divider {
            x: root.ethWidth
        }

        Item {
            id: timeSegment

            x: root.ethWidth + 1
            width: root.timeWidth
            height: parent.height
            clip: true

            HubView {
                anchors.fill: parent
                shown: Osd.message === ""

                Label {
                    text: Qt.formatTime(clock.date, "HH:mm")
                    color: Theme.accentFill
                    bold: true
                }

                Label {
                    text: Qt.formatDate(clock.date, "ddd d MMM")
                    caps: true
                    capHeight: Style.capHeight
                }
            }

            HubView {
                anchors.fill: parent
                shown: Osd.message === "volume"

                Label {
                    text: Audio.icon
                }

                Item {
                    implicitWidth: meter.width
                    implicitHeight: Style.pillHeight

                    SegMeter {
                        id: meter

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
                shown: Osd.message === "layout"

                Chip {
                    text: Keyboard.layout
                }

                Label {
                    text: Keyboard.shortName
                }
            }

            // The last seconds before the idle lock, inverted with the alert hatch.
            HubView {
                anchors.fill: parent
                shown: Osd.message === "lock"

                CutRect {
                    anchors.fill: parent
                    anchors.topMargin: Style.buttonInset
                    anchors.bottomMargin: Style.buttonInset
                    cut: Style.cellCut
                    color: Theme.foreground
                    hatch: true
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

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openDashboard()
            }
        }

        Divider {
            visible: root.headlineInDisplay
            x: root.ethWidth + 1 + root.timeWidth
        }

        Loader {
            active: root.headlineInDisplay
            x: root.ethWidth + 2 + root.timeWidth
            width: root.headlineWidth
            height: parent.height
            sourceComponent: headline
        }
    }

    // The headline's own display, used when it does not fit right of the time.
    CutRect {
        id: headlineDisplay

        readonly property bool shown: !root.headlineInDisplay && root.headlineWidth >= root.minHeadlineWidth / 2

        visible: shown
        x: root.leftLimit + root.gap
        width: root.headlineWidth
        height: Style.pillHeight
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.glass
        edge: "sunken"

        Loader {
            active: headlineDisplay.shown
            anchors.fill: parent
            sourceComponent: headline
        }
    }

    Component {
        id: headline

        Item {
            LabelValue {
                x: root.pad
                label: "HN"
                value: HackerNews.current?.title ?? "…"
                maxValueWidth: root.headlineWidth - 2 * root.pad - Math.ceil(hnLabelMetrics.advanceWidth) - Style.labelSpacing
            }

            MouseArea {
                anchors.fill: parent
                enabled: HackerNews.current !== null
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton)
                        HackerNews.openDiscussion(HackerNews.current);
                    else
                        HackerNews.open(HackerNews.current);
                }
            }
        }
    }
}

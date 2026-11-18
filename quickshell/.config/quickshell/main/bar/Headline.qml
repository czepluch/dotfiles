// The current Hacker News title as plain text in the link color, cut off
// with "…" to fit maxWidth and, when maxChars is set, that many characters.
// Hidden while there is no story or less than minWidth of room. Clicking
// opens the story; right-clicking opens the discussion.
import QtQuick
import qs
import qs.components
import qs.services

Item {
    id: root

    // False hides the headline, as on the lock screen.
    property bool shown: true
    // Room for the whole headline, padding included.
    property real maxWidth: 0
    // Longest title in characters, "…" included; 0 means no limit.
    property int maxChars: 0
    readonly property int minWidth: 160
    readonly property int padding: Style.textPadding
    // The font is monospaced, so a character limit is a width limit.
    readonly property real textLimit: {
        const room = maxWidth - 2 * padding;
        return maxChars > 0 ? Math.min(room, maxChars * charMetrics.advanceWidth) : room;
    }

    visible: shown && HackerNews.current !== null && maxWidth >= minWidth
    implicitWidth: title.implicitWidth + 2 * padding
    implicitHeight: Style.pillHeight

    TextMetrics {
        id: charMetrics

        text: "0"
        font.family: Theme.fontFamily
        font.pixelSize: Style.size
    }

    Label {
        id: title

        x: root.padding
        text: HackerNews.current?.title ?? ""
        color: Theme.info
        maxWidth: Math.max(1, Math.floor(root.textLimit))
    }

    MouseArea {
        anchors.fill: parent
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

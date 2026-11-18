pragma Singleton

// Sizes, type scale, motion and input steps shared by the shell's parts.
// Every container height has the same parity as the cap height of the text
// centered in it, so the text lands on whole pixels. Corners are round, with
// smaller radii for smaller parts.
import QtQuick
import Quickshell
import qs

Singleton {
    id: root

    // Type scale: uppercase labels, chips and toggles; lists and the
    // calendar; bar text; the large time.
    readonly property int labelSize: 13
    readonly property int smallSize: 15
    readonly property int size: 17
    readonly property int displaySize: 52

    // Cap heights measured from the font (digit height for the display size).
    readonly property int labelCap: capOf(labelMetrics, "H")
    readonly property int smallCap: capOf(smallMetrics, "H")
    readonly property int capHeight: capOf(mainMetrics, "H")
    readonly property int displayCap: capOf(displayMetrics, "0")

    // Bar panels, buttons and chips.
    readonly property int pillHeight: fit(2 * size - 1, capHeight)
    readonly property int inset: 4
    readonly property int height: pillHeight + 2 * inset
    readonly property int buttonInset: 3
    readonly property int buttonSize: pillHeight - 2 * buttonInset
    readonly property int chipHeight: fit(buttonSize - 2, labelCap)
    readonly property int chipPadding: 8
    readonly property int iconSize: pillHeight - 12

    // Popups: list rows, section headings and the large time.
    readonly property int rowHeight: fit(30, smallCap)
    readonly property int sectionHeight: fit(18, labelCap)
    readonly property int displayHeight: fit(84, displayCap)
    readonly property int popupPadding: 16
    readonly property int popupSpacing: 12
    // Space between buttons in a popup grid.
    readonly property int gap: 6

    // Corner radii: surfaces, panels, and cells and chips; and the curves
    // where a popup joins the bar.
    readonly property int surfaceRadius: 12
    readonly property int panelRadius: 10
    readonly property int cellRadius: 7
    readonly property int joinRadius: 12

    // Horizontal space around text in panels, between a label and its value,
    // and between text and the edge of an alert fill around it.
    readonly property int textPadding: 10
    readonly property int labelSpacing: 6
    readonly property int alertPadding: 5
    readonly property int dividerHeight: 17

    // Lock screen: the large time, the date and password text,
    // padding inside the display and gaps between its parts.
    readonly property int lockTimeSize: 136
    readonly property int lockTextSize: 22
    readonly property int lockTimeCap: capOf(lockTimeMetrics, "0")
    readonly property int lockTextCap: capOf(lockTextMetrics, "H")
    readonly property int lockPadding: 40
    readonly property int lockGap: 24
    readonly property int lockFieldWidth: 560
    // Password dots: size and gap, and how many the slot must show at least.
    readonly property int lockDotSize: 12
    readonly property int lockDotGap: 4
    readonly property int lockMinDots: 30
    readonly property int lockFieldHeight: fit(56, lockTextCap)

    // Screens narrower than this get the compact bar: a shorter headline and
    // no ETH 24 h change.
    readonly property int compactWidth: 3840
    readonly property int compactHeadlineChars: 40

    // Space between the bar and the screen edges. Matches Hyprland's
    // gaps_out, so the bar lines up with the outer edge of window borders.
    readonly property int screenMargin: 3

    // Motion in ms, all zero when reduceMotion is set, and the distance a
    // short message slides when it appears.
    property bool reduceMotion: false
    readonly property int hoverIn: reduceMotion ? 0 : 90
    readonly property int hoverOut: reduceMotion ? 0 : 150
    readonly property int change: reduceMotion ? 0 : 150
    readonly property int slide: 8
    // The lock display growing out of the hub, shrinking back on unlock, and
    // the delay before the password slot fades in.
    readonly property int lockGrow: reduceMotion ? 0 : 650
    readonly property int lockShrink: reduceMotion ? 0 : 400
    readonly property int lockLateDelay: reduceMotion ? 0 : 450

    // Mouse wheel: angle delta of one notch, and how much one notch changes
    // a value from 0 to 1 (volume, brightness).
    readonly property int wheelNotch: 120
    readonly property real wheelValueStep: 0.02

    function capOf(metrics, glyph) {
        return Math.round(-metrics.tightBoundingRect(glyph).y);
    }

    // Cap height for one of the sizes in the type scale.
    function capHeightAt(size) {
        switch (size) {
        case labelSize:
            return labelCap;
        case smallSize:
            return smallCap;
        case displaySize:
            return displayCap;
        case lockTimeSize:
            return lockTimeCap;
        case lockTextSize:
            return lockTextCap;
        default:
            return capHeight;
        }
    }

    // The smallest height of at least base with the same parity as cap.
    function fit(base, cap) {
        return base + Math.abs(base - cap) % 2;
    }

    FontMetrics {
        id: labelMetrics

        font.family: Theme.fontFamily
        font.pixelSize: root.labelSize
    }

    FontMetrics {
        id: smallMetrics

        font.family: Theme.fontFamily
        font.pixelSize: root.smallSize
    }

    FontMetrics {
        id: mainMetrics

        font.family: Theme.fontFamily
        font.pixelSize: root.size
    }

    FontMetrics {
        id: lockTimeMetrics

        font.family: Theme.fontFamily
        font.pixelSize: root.lockTimeSize
        font.bold: true
    }

    FontMetrics {
        id: lockTextMetrics

        font.family: Theme.fontFamily
        font.pixelSize: root.lockTextSize
    }

    FontMetrics {
        id: displayMetrics

        font.family: Theme.fontFamily
        font.pixelSize: root.displaySize
    }
}

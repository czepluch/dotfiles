pragma ComponentBehavior: Bound

// The panel of the app launcher, the session menu and the clipboard history
// (see Launcher): a search field and a list. Typing filters the list; Up
// and Down (or Ctrl+K and Ctrl+J) move the selection, Enter or a click runs
// it, Escape closes. Log out, Reboot and Power off ask first: the first
// press turns the entry red, and a second one within 3 s runs it. In the
// clipboard history, an × on the entry under the mouse deletes it, and
// "Clear all" in the search field deletes them all after the same second
// press. The panel keeps its size while the list gets shorter.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.components
import qs.services

RoundRect {
    id: root

    readonly property string mode: Launcher.mode
    // Width of the list before Style.launcherScale and number of rows of
    // Style.launcherRow it shows.
    readonly property var layout: ({
            apps: { width: 420, rows: 8, placeholder: "Search apps" },
            session: { width: 260, rows: 5, placeholder: "Session" },
            clipboard: { width: 560, rows: 10, placeholder: "Search clipboard" }
        })[mode] ?? { width: 420, rows: 8, placeholder: "" }
    readonly property int listWidth: Math.round(layout.width * Style.launcherScale)
    readonly property var sessionItems: [
        { name: "Lock", glyph: "󰌾", run: () => Quickshell.execDetached(["loginctl", "lock-session"]) },
        { name: "Log out", glyph: "󰍃", confirm: true, run: () => Hyprland.dispatch("hl.dsp.exit()") },
        { name: "Suspend", glyph: "󰒲", run: () => Quickshell.execDetached(["systemctl", "suspend"]) },
        { name: "Reboot", glyph: "󰜉", confirm: true, run: () => Quickshell.execDetached(["systemctl", "reboot"]) },
        { name: "Power off", glyph: "󰐥", confirm: true, run: () => Quickshell.execDetached(["systemctl", "poweroff"]) }
    ]
    property string query: ""
    property int selected: 0
    // Index of the entry that waits for a second press, or -1.
    property int confirming: -1
    // "Clear all" waits for a second press.
    property bool clearConfirming: false
    // Where the mouse was last seen over the list, in window coordinates;
    // null until it is first seen after opening.
    property var pointer: null
    // Entries as { name, detail, icon, glyph, preview, confirm, run }.
    readonly property var items: {
        switch (mode) {
        case "apps":
            return Apps.search(query).map(entry => {
                const icon = Quickshell.iconPath(entry.icon, true);
                return {
                    name: entry.name,
                    detail: entry.genericName,
                    icon: icon,
                    glyph: icon === "" ? "󰀻" : "",
                    run: () => Apps.launch(entry)
                };
            });
        case "session":
            return sessionItems.filter(item => query.trim() === "" || Apps.score(item.name, query.trim().toLowerCase()) > 0);
        case "clipboard":
            return ClipHistory.search(query).map(entry => {
                const preview = entry.image ? ClipHistory.previews[entry.id] ?? "" : "";
                return {
                    name: entry.image ? "Image" : entry.text,
                    detail: entry.image ? entry.width + "×" + entry.height + " · " + entry.size : "",
                    glyph: preview !== "" ? "" : entry.image ? "󰋩" : "󰅍",
                    preview: preview,
                    image: entry.image ?? false,
                    run: () => ClipHistory.copy(entry),
                    remove: () => ClipHistory.remove(entry)
                };
            });
        default:
            return [];
        }
    }

    function move(step) {
        if (items.length === 0)
            return;
        selected = (selected + step + items.length) % items.length;
        list.positionViewAtIndex(selected, ListView.Contain);
    }

    function activate(index) {
        const item = items[index];
        if (!item)
            return;
        if (item.confirm && confirming !== index) {
            selected = index;
            confirming = index;
            confirmTimer.restart();
            return;
        }
        Launcher.close();
        item.run();
    }

    function clearAll() {
        if (!clearConfirming) {
            clearConfirming = true;
            confirmTimer.restart();
            return;
        }
        clearConfirming = false;
        ClipHistory.wipe();
    }

    onModeChanged: {
        field.text = "";
        selected = 0;
        confirming = -1;
        clearConfirming = false;
        pointer = null;
        if (mode === "clipboard")
            ClipHistory.refresh();
        if (mode !== "")
            field.forceActiveFocus();
    }
    onQueryChanged: {
        selected = 0;
        confirming = -1;
        list.positionViewAtBeginning();
    }
    onSelectedChanged: {
        if (confirming !== selected)
            confirming = -1;
    }

    width: listWidth + 2 * Style.launcherPadding
    height: column.implicitHeight + 2 * Style.launcherPadding
    radius: Style.surfaceRadius
    color: Theme.barFill
    outline: Theme.outline
    edge: "raised"

    Timer {
        id: confirmTimer

        interval: 3000
        onTriggered: {
            root.confirming = -1;
            root.clearConfirming = false;
        }
    }

    Column {
        id: column

        x: Style.launcherPadding
        y: Style.launcherPadding
        spacing: Style.launcherSpacing

        RoundRect {
            width: root.listWidth
            height: Style.launcherField
            color: Theme.glass

            Label {
                x: Style.launcherInset
                height: parent.height
                text: "󰍉"
                size: Style.launcherSize
                color: Theme.dim
            }

            TextInput {
                id: field

                x: Style.launcherInset + Style.launcherIcon + Style.launcherInset
                width: (clear.visible ? clear.x : parent.width) - x - Style.launcherInset
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                color: Theme.foreground
                selectionColor: Theme.glass
                font.family: Theme.fontFamily
                font.pixelSize: Style.launcherSize
                onTextChanged: root.query = text
                Keys.onPressed: event => {
                    const ctrl = event.modifiers & Qt.ControlModifier;
                    if (event.key === Qt.Key_Escape)
                        Launcher.close();
                    else if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_J))
                        root.move(1);
                    else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_K))
                        root.move(-1);
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        root.activate(root.selected);
                    else
                        return;
                    event.accepted = true;
                }

                Text {
                    visible: field.text === ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.layout.placeholder
                    color: Theme.faint
                    font: field.font
                }
            }

            Clickable {
                id: clear

                visible: root.mode === "clipboard" && ClipHistory.items.length > 0
                anchors.right: parent.right
                anchors.rightMargin: Style.launcherEdge
                anchors.verticalCenter: parent.verticalCenter
                // As wide as "Clear all" while it asks, so that a second
                // click in the same place hits it.
                width: Math.ceil(clearMetrics.advanceWidth) + 2 * Style.launcherInset
                height: parent.height - 2 * Style.launcherEdge
                baseColor: root.clearConfirming ? Theme.bad : "transparent"
                onClicked: root.clearAll()

                TextMetrics {
                    id: clearMetrics

                    font.family: Theme.fontFamily
                    font.pixelSize: Style.launcherSize
                    text: "Clear all"
                }

                Label {
                    id: clearLabel

                    anchors.centerIn: parent
                    height: parent.height
                    text: root.clearConfirming ? "Sure?" : "Clear all"
                    size: Style.launcherSize
                    bold: root.clearConfirming
                    color: root.clearConfirming ? Theme.textOn(Theme.bad) : Theme.dim
                }
            }
        }

        ListView {
            id: list

            width: root.listWidth
            height: root.layout.rows * (Style.launcherRow + spacing) - spacing
            clip: true
            spacing: Style.launcherRowGap
            boundsBehavior: Flickable.StopAtBounds
            model: root.items

            delegate: LauncherRow {
                id: row

                required property var modelData
                required property int index

                width: list.width
                item: modelData
                selected: index === root.selected
                confirming: index === root.confirming
                trailing: modelData.remove !== undefined ? remove.width + Style.launcherEdge : 0

                // Selects the entry when the mouse moves onto it, not when the
                // list moves under a resting mouse.
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: mouse => {
                        const p = mapToItem(null, mouse.x, mouse.y);
                        const moved = root.pointer !== null && (p.x !== root.pointer.x || p.y !== root.pointer.y);
                        root.pointer = p;
                        if (moved)
                            root.selected = row.index;
                    }
                    onClicked: root.activate(row.index)
                }

                // Deletes the entry from the clipboard history.
                Clickable {
                    id: remove

                    visible: row.hovered && row.modelData.remove !== undefined
                    anchors.right: parent.right
                    anchors.rightMargin: Style.launcherEdge
                    anchors.verticalCenter: parent.verticalCenter
                    width: Style.launcherIcon + Style.launcherEdge
                    height: width
                    onClicked: row.modelData.remove()

                    Label {
                        anchors.fill: parent
                        text: "󰅖"
                        size: Style.launcherSize
                        color: Theme.dim
                    }
                }
            }

            Label {
                visible: list.count === 0
                width: list.width
                height: Style.launcherRow
                text: root.mode === "clipboard" && ClipHistory.items.length === 0 ? "Clipboard history is empty" : "No matches"
                size: Style.launcherSize
                color: Theme.dim
            }
        }
    }
}

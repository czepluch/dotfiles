pragma ComponentBehavior: Bound

// The panel of the app launcher, the session menu, the clipboard history
// and the palette and wallpaper pickers (see Launcher): a search field and
// a list (a grid for the wallpapers). Typing filters it; Up and Down (or
// Ctrl+K and Ctrl+J) move the selection, and Left and Right in the grid;
// Enter or a click runs it, Escape closes. Log out, Reboot and Power off ask
// first: the first press turns the entry red, and a second one within 3 s
// runs it. In the clipboard history, an × on the entry under the mouse
// deletes it, and "Clear all" in the search field deletes them all after
// the same second press. The theme pickers start on the palette or
// wallpaper in use and apply each one the selection moves to (see Themes);
// Enter keeps it, and closing any other way goes back. The panel keeps its
// size while the list gets shorter.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.components
import qs.services

RoundRect {
    id: root

    readonly property string mode: Launcher.mode
    // Width of the list before Style.launcherScale, number of rows it shows
    // and their height (in the wallpaper grid, tileHeight).
    readonly property var layout: ({
            apps: { width: 420, rows: 8, rowHeight: Style.launcherRow, placeholder: "Search apps" },
            session: { width: 260, rows: 5, rowHeight: Style.launcherRow, placeholder: "Session" },
            clipboard: { width: 560, rows: 10, rowHeight: Style.launcherRow, placeholder: "Search clipboard" },
            palettes: { width: 560, rows: 6, rowHeight: Style.launcherImageRow, placeholder: "Search palettes" },
            wallpapers: { width: 560, rows: 3, rowHeight: 0, placeholder: "Search wallpapers" }
        })[mode] ?? { width: 420, rows: 8, rowHeight: Style.launcherRow, placeholder: "" }
    readonly property int listWidth: Math.round(layout.width * Style.launcherScale)
    readonly property bool themeMode: mode === "palettes" || mode === "wallpapers"
    readonly property bool grid: mode === "wallpapers"
    // A cell of the wallpaper grid; the tile in it leaves a gap.
    readonly property int tileWidth: Math.floor(listWidth / Style.wallpaperColumns)
    readonly property int tileHeight: Math.round((tileWidth - Style.launcherRowGap - 2 * Style.launcherEdge) * 0.625)
        + 4 * Style.launcherEdge + Style.launcherSmallCap + Style.launcherRowGap
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
    // The theme pickers apply the selection once they start on the entry in
    // use.
    property bool previewing: false
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
        case "palettes":
            return Themes.palettes.filter(p => query.trim() === "" || Apps.score(p.name, query.trim().toLowerCase()) > 0).map(p => ({
                        name: p.name,
                        detail: p.name === Themes.startPalette ? "current" : "",
                        preview: p.wallpaper !== "" ? Themes.previews[p.wallpaper] ?? "" : "",
                        crop: true,
                        image: true,
                        // Shown until the preview is made, and for a palette without a wallpaper.
                        block: { background: p.background, foreground: p.foreground },
                        swatches: [p.accent].concat(p.colors).filter(c => c !== ""),
                        current: p.name === Themes.startPalette,
                        apply: () => Themes.applyPalette(p.name)
                    }));
        case "wallpapers":
            return Themes.wallpapers.map(path => ({
                        name: path.replace(/^.*\//, "").replace(/\.\w+$/, ""),
                        preview: Themes.previews[path] ?? "",
                        current: path === Themes.startWallpaper,
                        apply: () => Themes.applyWallpaper(path)
                    })).filter(w => query.trim() === "" || Apps.score(w.name, query.trim().toLowerCase()) > 0);
        default:
            return [];
        }
    }

    function move(step) {
        if (items.length === 0)
            return;
        selected = (selected + step + items.length) % items.length;
        if (grid)
            tiles.positionViewAtIndex(selected, GridView.Contain);
        else
            list.positionViewAtIndex(selected, ListView.Contain);
    }

    // Selects an entry when the mouse moves onto it, not when the list moves
    // under a resting mouse.
    function pointed(area, mouse, index) {
        const p = area.mapToItem(null, mouse.x, mouse.y);
        const moved = pointer !== null && (p.x !== pointer.x || p.y !== pointer.y);
        pointer = p;
        if (moved)
            selected = index;
    }

    function applySelected() {
        if (previewing)
            items[selected]?.apply?.();
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
        if (item.apply)
            item.apply();
        else
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
        previewing = false;
        field.text = "";
        selected = 0;
        confirming = -1;
        clearConfirming = false;
        pointer = null;
        if (mode === "clipboard")
            ClipHistory.refresh();
        // Derived properties such as themeMode may not follow mode yet here.
        if (mode === "palettes" || mode === "wallpapers")
            Themes.begin();
        if (mode !== "")
            field.forceActiveFocus();
    }
    onQueryChanged: {
        selected = 0;
        confirming = -1;
        list.positionViewAtBeginning();
        tiles.positionViewAtBeginning();
        applySelected();
    }
    onSelectedChanged: {
        if (confirming !== selected)
            confirming = -1;
        applySelected();
    }

    // Starts the theme pickers on the entry in use.
    Connections {
        target: Themes

        function onReadyChanged() {
            if (!Themes.ready || !root.themeMode || root.previewing)
                return;
            root.selected = Math.max(0, root.items.findIndex(item => item.current));
            root.move(0);
            root.previewing = true;
        }
    }

    Connections {
        target: Launcher

        function onCancelled(mode) {
            if (mode === "palettes" || mode === "wallpapers")
                Themes.revert();
        }
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
                    const row = root.grid ? Style.wallpaperColumns : 1;
                    if (event.key === Qt.Key_Escape)
                        Launcher.cancel();
                    else if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_J))
                        root.move(row);
                    else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_K))
                        root.move(-row);
                    else if (root.grid && event.key === Qt.Key_Right)
                        root.move(1);
                    else if (root.grid && event.key === Qt.Key_Left)
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

            visible: !root.grid
            width: root.listWidth
            height: root.layout.rows * (root.layout.rowHeight + spacing) - spacing
            clip: true
            spacing: Style.launcherRowGap
            boundsBehavior: Flickable.StopAtBounds
            model: root.grid ? [] : root.items

            delegate: LauncherRow {
                id: row

                required property var modelData
                required property int index

                width: list.width
                item: modelData
                selected: index === root.selected
                confirming: index === root.confirming
                trailing: modelData.remove !== undefined ? remove.width + Style.launcherEdge : 0

                MouseArea {
                    id: rowArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: mouse => root.pointed(rowArea, mouse, row.index)
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
                text: root.mode === "clipboard" && ClipHistory.items.length === 0 ? "Clipboard history is empty"
                    : root.themeMode && !Themes.ready ? "Loading…" : "No matches"
                size: Style.launcherSize
                color: Theme.dim
            }
        }

        GridView {
            id: tiles

            visible: root.grid
            width: root.listWidth
            height: root.layout.rows * cellHeight
            clip: true
            cellWidth: root.tileWidth
            cellHeight: root.tileHeight
            boundsBehavior: Flickable.StopAtBounds
            model: root.grid ? root.items : []

            delegate: LauncherTile {
                id: tile

                required property var modelData
                required property int index

                width: root.tileWidth - Style.launcherRowGap
                height: root.tileHeight - Style.launcherRowGap
                item: modelData
                selected: index === root.selected

                MouseArea {
                    id: tileArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: mouse => root.pointed(tileArea, mouse, tile.index)
                    onClicked: root.activate(tile.index)
                }
            }

            Label {
                visible: tiles.count === 0
                width: tiles.width
                height: Style.launcherRow
                text: !Themes.ready ? "Loading…" : "No matches"
                size: Style.launcherSize
                color: Theme.dim
            }
        }
    }
}

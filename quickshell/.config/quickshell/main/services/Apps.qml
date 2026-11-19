pragma Singleton

// Applications from their desktop entries, ranked for the launcher: first
// by how well they match the query, then by how often each was launched.
// The name counts most (see score); a word of the generic name or a
// keyword that starts with the query ranks above the name's letters in
// order, and one that only contains it ranks last. The counts are kept in
// the shell's state directory; the first time, they start from fuzzel's
// counts in ~/.cache/fuzzel. An app runs through Hyprland, so it does not
// belong to the shell's service and keeps running when the shell restarts;
// a terminal app runs in Ghostty.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    // Desktop entry id -> number of launches.
    property var counts: ({})
    readonly property var entries: Array.from(DesktopEntries.applications.values)

    // Entries that match the query, best first; all of them, most launched
    // first, for an empty query.
    function search(query) {
        const q = query.trim().toLowerCase();
        const ranked = [];
        for (const entry of entries) {
            const other = Math.max(score(entry.genericName, q), ...entry.keywords.map(k => score(k, q)));
            const match = q === "" ? 0 : Math.max(score(entry.name, q), other >= 3 ? 1.5 : other === 2 ? 0.5 : -1);
            if (match >= 0)
                ranked.push({ entry: entry, match: match, count: counts[entry.id] ?? 0 });
        }
        ranked.sort((a, b) => b.match - a.match || b.count - a.count || a.entry.name.localeCompare(b.entry.name));
        return ranked.map(r => r.entry);
    }

    // How well text matches a lowercase query: 4 when it starts with the
    // query, 3 when a word in it does, 2 when it contains it, 1 when it
    // contains its letters in order, -1 when it does not match.
    function score(text, q) {
        const t = text.toLowerCase();
        if (t.startsWith(q))
            return 4;
        let at = t.indexOf(q);
        while (at > 0 && /[a-z0-9]/.test(t[at - 1]))
            at = t.indexOf(q, at + 1);
        if (at > 0)
            return 3;
        if (t.includes(q))
            return 2;
        let from = 0;
        for (const ch of q) {
            const found = t.indexOf(ch, from);
            if (found < 0)
                return -1;
            from = found + 1;
        }
        return 1;
    }

    function launch(entry) {
        counts = Object.assign({}, counts, { [entry.id]: (counts[entry.id] ?? 0) + 1 });
        store.setText(JSON.stringify(counts));
        const command = entry.command.map(arg => "'" + arg.replace(/'/g, "'\\''") + "'").join(" ");
        const line = entry.runInTerminal ? "ghostty -e " + command : command;
        Hyprland.dispatch("hl.dsp.exec_cmd(" + JSON.stringify(line) + ")");
    }

    // Set when there are no counts of our own yet.
    property bool importing: false

    // Takes the counts from fuzzel's lines of "<id>.desktop|<count>".
    function importFuzzel() {
        const counts = {};
        for (const line of fuzzel.text().split("\n")) {
            const [file, count] = line.split("|");
            if (file && count)
                counts[file.replace(/\.desktop$/, "")] = Number(count);
        }
        importing = false;
        root.counts = Object.assign(counts, root.counts);
        store.setText(JSON.stringify(root.counts));
    }

    FileView {
        id: store

        path: Quickshell.statePath("launches.json")
        printErrors: false
        onLoaded: {
            try {
                root.counts = JSON.parse(text());
            } catch (e) {
                console.warn("Apps: cannot read", path, e);
            }
        }
        onLoadFailed: {
            root.importing = true;
            if (fuzzel.loaded)
                root.importFuzzel();
        }
    }

    FileView {
        id: fuzzel

        path: Quickshell.env("HOME") + "/.cache/fuzzel"
        printErrors: false
        onLoaded: {
            if (root.importing)
                root.importFuzzel();
        }
    }
}

pragma Singleton

// The clipboard history from cliphist, newest first, read again by
// refresh() each time the picker opens and after each change. The newest 30
// images are decoded into the runtime directory, once each, for small
// previews. Copying an entry puts it back on the clipboard through
// Hyprland, so wl-copy keeps serving it when the shell restarts. remove()
// deletes one entry, wipe() the whole history.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    // { id, text } for text, { id, image: true, format, size, width,
    // height } for an image.
    property var items: []
    // Entry id -> file URL of its decoded image.
    property var previews: ({})
    readonly property string previewDir: Quickshell.env("XDG_RUNTIME_DIR") + "/quickshell-clipboard"
    readonly property int maxPreviews: 30

    // Set when a refresh is asked for while one runs.
    property bool rerun: false

    function refresh() {
        if (lister.running)
            rerun = true;
        else
            lister.running = true;
    }

    // Deletes an entry and its preview.
    function remove(item) {
        run(["sh", "-c", 'printf "%s\\t\\n" "$1" | cliphist delete; rm -f "$2/$1".*', "sh", item.id, previewDir]);
    }

    // Deletes the whole history and the previews.
    function wipe() {
        run(["sh", "-c", 'cliphist wipe; rm -rf "$1"', "sh", previewDir]);
    }

    function run(command) {
        const process = action.createObject(root, { command: command });
        process.exited.connect(() => {
            root.refresh();
            process.destroy();
        });
        process.running = true;
    }

    // Entries whose text contains the query; "image" finds the images.
    function search(query) {
        const q = query.trim().toLowerCase();
        if (q === "")
            return items;
        return items.filter(item => (item.image ? "image" : item.text.toLowerCase()).includes(q));
    }

    function copy(item) {
        Hyprland.dispatch("hl.dsp.exec_cmd(" + JSON.stringify("cliphist decode " + item.id + " | wl-copy") + ")");
    }

    Component {
        id: action

        Process {}
    }

    // Lines of "<id>\t<text>"; an image reads
    // "[[ binary data 54 KiB png 1586x378 ]]".
    Process {
        id: lister

        command: ["cliphist", "list"]
        onExited: {
            if (root.rerun) {
                root.rerun = false;
                running = true;
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                const items = [];
                for (const line of text.split("\n")) {
                    const tab = line.indexOf("\t");
                    if (tab < 1)
                        continue;
                    const id = line.slice(0, tab);
                    const content = line.slice(tab + 1);
                    const image = /^\[\[ binary data (.+) (\w+) (\d+)x(\d+) \]\]$/.exec(content);
                    if (image)
                        items.push({ id: id, image: true, size: image[1], format: image[2], width: Number(image[3]), height: Number(image[4]) });
                    else
                        items.push({ id: id, text: content });
                }
                root.items = items;
                const files = items.filter(item => item.image).slice(0, root.maxPreviews).map(item => item.id + "." + item.format);
                if (files.length > 0) {
                    decoder.command = ["sh", "-c", decoder.script, "sh", root.previewDir].concat(files);
                    decoder.running = true;
                }
            }
        }
    }

    // Decodes each "<id>.<format>" that is not there yet and prints the
    // names of the files that are.
    Process {
        id: decoder

        readonly property string script: 'dir=$1; shift; mkdir -p "$dir" && for f; do [ -s "$dir/$f" ] || cliphist decode "${f%.*}" > "$dir/$f"; [ -s "$dir/$f" ] && echo "$f"; done'

        stdout: StdioCollector {
            onStreamFinished: {
                const previews = {};
                for (const file of text.split("\n")) {
                    if (file !== "")
                        previews[file.replace(/\.\w+$/, "")] = "file://" + root.previewDir + "/" + file;
                }
                root.previews = previews;
            }
        }
    }
}

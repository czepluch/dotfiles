pragma Singleton

// Palettes and wallpapers for the theme pickers (see Launcher). begin()
// reads them again: the palettes from themes/palettes/ in the dotfiles (the
// one in use is the one colors.toml is a copy of, as in theme-set), the
// images in ~/pics/wallpapers/ and the wallpaper hyprpaper shows. Small
// previews are made once with ImageMagick into the shell's cache directory.
//
// The pickers apply each entry as the selection moves: a palette with
// theme-set, a wallpaper with theme-wallpaper. While one runs, only the
// newest request waits. revert() goes back to the palette and wallpaper
// from begin(). The commands run with mise's shims on the PATH, so that
// theme-set also reaches herdr.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string bin: home + "/dotfiles/themes/bin/"
    readonly property string themesDir: home + "/dotfiles/themes"
    readonly property string wallpaperDir: home + "/pics/wallpapers"
    readonly property string previewDir: Quickshell.cachePath("wallpapers")
    // { name, accent, background, foreground, colors (6), wallpaper (path
    // or "") }, by name.
    property var palettes: []
    // Image paths, by name.
    property var wallpapers: []
    property string palette: ""
    property string wallpaper: ""
    // The palette and wallpaper at begin().
    property string startPalette: ""
    property string startWallpaper: ""
    // Set once all three have been read after begin().
    readonly property bool ready: palettesRead && wallpapersRead && activeRead
    property bool palettesRead: false
    property bool wallpapersRead: false
    property bool activeRead: false
    // Image path -> file URL of its preview, once made.
    property var previews: ({})
    // The newest command waiting while another runs, or null.
    property var pending: null

    function begin() {
        palettesRead = false;
        wallpapersRead = false;
        activeRead = false;
        paletteReader.running = true;
        wallpaperLister.running = true;
        activeReader.running = true;
    }

    function applyPalette(name) {
        if (name === palette)
            return;
        palette = name;
        run([bin + "theme-set", name]);
    }

    function applyWallpaper(path) {
        if (path === wallpaper)
            return;
        wallpaper = path;
        run([bin + "theme-wallpaper", path]);
    }

    function revert() {
        const commands = [];
        if (startPalette !== "" && palette !== startPalette)
            commands.push('"$1theme-set" "$2" > /dev/null');
        if (startWallpaper !== "" && (wallpaper !== startWallpaper || commands.length > 0))
            commands.push('"$1theme-wallpaper" "$3" > /dev/null');
        if (commands.length === 0)
            return;
        palette = startPalette;
        wallpaper = startWallpaper;
        run(["sh", "-c", commands.join("; "), "sh", bin, startPalette, startWallpaper]);
    }

    function run(command) {
        if (runner.running) {
            pending = command;
        } else {
            runner.command = command;
            runner.running = true;
        }
    }

    function expand(path) {
        return path.startsWith("~/") ? home + path.slice(1) : path;
    }

    // Makes the previews that are missing, for the wallpapers and the
    // palettes' own wallpapers.
    function makePreviews() {
        const paths = wallpapers.concat(palettes.map(p => p.wallpaper).filter(w => w !== ""));
        previewer.command = ["sh", "-c", previewer.script, "sh", previewDir].concat(Array.from(new Set(paths)));
        previewer.running = true;
    }

    Process {
        id: runner

        environment: ({
                PATH: root.home + "/.local/share/mise/shims:" + Quickshell.env("PATH")
            })
        onExited: exitCode => {
            if (exitCode !== 0)
                console.warn("Themes:", command.join(" "), "failed with exit code", exitCode);
            if (root.pending) {
                const next = root.pending;
                root.pending = null;
                Qt.callLater(() => root.run(next));
            }
        }
    }

    // Each palette file after a line "\f<path>", then colors.toml after
    // "\fcolors".
    Process {
        id: paletteReader

        command: ["sh", "-c", 'for f in "$1"/palettes/*.toml; do printf "\\f%s\\n" "$f"; cat "$f"; done; printf "\\fcolors\\n"; cat "$1/colors.toml"', "sh", root.themesDir]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.split("\f").filter(p => p !== "");
                const files = parts.map(part => {
                    const newline = part.indexOf("\n");
                    return { path: part.slice(0, newline), text: part.slice(newline + 1) };
                });
                const colors = files.find(f => f.path === "colors")?.text ?? "";
                const palettes = [];
                let current = "";
                for (const file of files) {
                    if (file.path === "colors")
                        continue;
                    const values = {};
                    for (const line of file.text.split("\n")) {
                        const match = /^\s*([\w-]+)\s*=\s*"([^"]*)"/.exec(line);
                        if (match)
                            values[match[1]] = match[2];
                    }
                    const name = file.path.replace(/^.*\//, "").replace(/\.toml$/, "");
                    palettes.push({
                        name: name,
                        accent: values.accent ?? "",
                        background: values.background ?? "",
                        foreground: values.foreground ?? "",
                        colors: [1, 2, 3, 4, 5, 6].map(i => values["color" + i] ?? ""),
                        wallpaper: values.wallpaper ? root.expand(values.wallpaper) : ""
                    });
                    if (file.text === colors)
                        current = name;
                }
                root.palettes = palettes;
                root.palette = current;
                root.startPalette = current;
                root.palettesRead = true;
                if (root.wallpapersRead)
                    root.makePreviews();
            }
        }
    }

    Process {
        id: wallpaperLister

        command: ["find", "-H", root.wallpaperDir, "-maxdepth", "1", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpapers = text.split("\n").filter(line => line !== "").sort((a, b) => a.localeCompare(b));
                root.wallpapersRead = true;
                if (root.palettesRead)
                    root.makePreviews();
            }
        }
    }

    // Lines of "<monitor>: <path>"; the first one counts.
    Process {
        id: activeReader

        command: ["hyprctl", "hyprpaper", "listactive"]
        stdout: StdioCollector {
            onStreamFinished: {
                const match = /^[^:]+:\s*(\/.+)$/m.exec(text);
                root.wallpaper = match ? match[1].trim() : "";
                root.startWallpaper = root.wallpaper;
                root.activeRead = true;
            }
        }
    }

    // Makes "<dir>/<name>.jpg" for each image that has none yet and prints
    // each image path once its preview is there.
    Process {
        id: previewer

        readonly property string script: 'dir=$1; shift; mkdir -p "$dir"; for f; do t="$dir/$(basename "$f").jpg"; [ -s "$t" ] || magick "$f[0]" -auto-orient -thumbnail "480x300^" -gravity center -extent 480x300 -quality 85 "$t" 2> /dev/null; [ -s "$t" ] && printf "%s\\n" "$f"; done'

        stdout: SplitParser {
            onRead: line => {
                const previews = Object.assign({}, root.previews);
                previews[line] = "file://" + root.previewDir + "/" + line.replace(/^.*\//, "") + ".jpg";
                root.previews = previews;
            }
        }
    }
}

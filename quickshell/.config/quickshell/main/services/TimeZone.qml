pragma Singleton

// The system timezone: its name from timedated, and its abbreviation and
// UTC offset at the moment of the last refresh. Read in a new process each
// time, so a timezone change shows on the next refresh.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // IANA name, for example "Europe/Copenhagen".
    property string name: ""
    // Abbreviation, for example "CET".
    property string abbreviation: ""
    // Offset from UTC, for example "+01:00".
    property string offset: ""

    // Starting the query while one runs queues a single rerun.
    function refresh() {
        query.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: query

        command: ["sh", "-c", "timedatectl show -p Timezone --value && date +'%Z %:z'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length < 2) {
                    console.warn("Reading the timezone failed:", text);
                    return;
                }
                root.name = lines[0];
                [root.abbreviation, root.offset] = lines[1].split(" ");
            }
        }
    }
}

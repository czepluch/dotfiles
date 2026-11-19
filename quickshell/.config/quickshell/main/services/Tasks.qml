pragma Singleton

// The next tasks from husk: overdue tasks first, then upcoming ones by due
// date. husk reads its local copy of the CalDAV lists, so a refresh is fast.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int limit: 5
    // Tasks as { uid, summary, project, due (Date or null), allDay, overdue }.
    property var tasks: []
    // False when husk could not be run or its output could not be read.
    property bool available: true

    // Starting the query while one runs queues a single rerun.
    function refresh() {
        list.running = true;
    }

    // A due date from husk: "2026-11-25" (a whole day, local time) or a full
    // ISO date and time.
    function parseDue(text) {
        if (!text)
            return null;
        if (text.length === 10) {
            const parts = text.split("-").map(Number);
            return new Date(parts[0], parts[1] - 1, parts[2]);
        }
        return new Date(text);
    }

    // Whole days from now's date to date's date.
    function daysBetween(now, date) {
        const start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        const end = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        return Math.round((end - start) / 86400000);
    }

    // Short due label: the time (or "Today") for today, the weekday for the
    // next 6 days, the day and month otherwise.
    function dueLabel(task, now) {
        if (task.due === null)
            return "";
        const days = daysBetween(now, task.due);
        const time = task.allDay ? "" : Qt.formatTime(task.due, "HH:mm");
        const locale = Qt.locale("en_GB");
        if (days === 0)
            return task.allDay ? "Today" : time;
        if (days > 0 && days < 7)
            return task.due.toLocaleDateString(locale, "ddd") + (time !== "" ? " " + time : "");
        return task.due.toLocaleDateString(locale, "d MMM");
    }

    Process {
        id: list

        // Both views as one JSON array. Uses ~/.cargo/bin/husk when husk is
        // not on the PATH, as in systemd user services.
        command: ["sh", "-c", "husk=$(command -v husk || echo \"$HOME/.cargo/bin/husk\"); "
            + "{ \"$husk\" list --view overdue --json && \"$husk\" list --view upcoming --json; } | jq -cs add"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const seen = new Set();
                    const tasks = [];
                    for (const item of JSON.parse(text) ?? []) {
                        if (seen.has(item.uid))
                            continue;
                        seen.add(item.uid);
                        tasks.push({
                            uid: item.uid,
                            summary: item.summary,
                            project: item.project ?? "",
                            due: root.parseDue(item.due),
                            allDay: (item.due ?? "").length === 10,
                            overdue: item.overdue === true
                        });
                    }
                    tasks.sort((a, b) => {
                        if (a.overdue !== b.overdue)
                            return a.overdue ? -1 : 1;
                        if (a.due === null || b.due === null)
                            return (a.due === null) - (b.due === null);
                        return a.due - b.due;
                    });
                    root.tasks = tasks.slice(0, root.limit);
                    root.available = true;
                } catch (e) {
                    root.available = false;
                    console.warn("Reading husk tasks failed:", e);
                }
            }
        }
    }
}

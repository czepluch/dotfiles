pragma Singleton

// CPU usage, CPU package temperature and memory use, read from /proc and
// /sys while the session is active: CPU and temperature every 2 s, memory
// every 10 s.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // CPU usage from 0 to 1, smoothed over about 3 s for display.
    property real cpu: 0
    // Raw CPU usage samples from 0 to 1, oldest first, one per update.
    property var cpuHistory: []
    readonly property int historyLength: 30

    // Package temperature and the sensor's maximum, in °C.
    property real temp: 0
    property real tempMax: 100

    // Memory in use from 0 to 1 (total minus available).
    property real mem: 0
    // Share of the last 10 s in which some task waited for memory, in %.
    property real memPressure: 0

    readonly property bool tempAlert: temp >= tempMax - 10
    readonly property bool memAlert: memPressure >= 10

    readonly property int interval: 2000
    property int tick: 0
    property var lastCpu: null

    function parseStat(text) {
        // First line: "cpu user nice system idle iowait irq softirq steal guest guest_nice".
        // Guest time is already counted in user. iowait counts as idle.
        const fields = text.slice(0, text.indexOf("\n")).trim().split(/\s+/).slice(1, 9).map(Number);
        const idle = fields[3] + fields[4];
        const total = fields.reduce((a, b) => a + b, 0);
        if (lastCpu !== null && total > lastCpu.total) {
            const usage = Math.min(1, Math.max(0, 1 - (idle - lastCpu.idle) / (total - lastCpu.total)));
            const history = cpuHistory.concat([usage]);
            cpuHistory = history.slice(-historyLength);
            cpu = history.length === 1 ? usage : cpu + (1 - Math.exp(-interval / 3000)) * (usage - cpu);
        }
        lastCpu = { total: total, idle: idle };
    }

    function parseMeminfo(text) {
        const total = Number(/MemTotal:\s+(\d+)/.exec(text)?.[1] ?? 0);
        const available = Number(/MemAvailable:\s+(\d+)/.exec(text)?.[1] ?? 0);
        if (total > 0)
            mem = 1 - available / total;
    }

    Timer {
        interval: root.interval
        running: Session.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            procStat.reload();
            if (tempInput.path !== "")
                tempInput.reload();
            if (root.tick % 5 === 0) {
                meminfo.reload();
                memoryPressure.reload();
            }
            root.tick++;
        }
    }

    FileView {
        id: procStat

        path: "/proc/stat"
        onLoaded: root.parseStat(text())
    }

    FileView {
        id: meminfo

        path: "/proc/meminfo"
        onLoaded: root.parseMeminfo(text())
    }

    FileView {
        id: memoryPressure

        path: "/proc/pressure/memory"
        onLoaded: root.memPressure = Number(/some avg10=([\d.]+)/.exec(text())?.[1] ?? 0)
    }

    // hwmon numbers change between boots, so the coretemp sensor is found by name.
    // temp1 is the package sensor ("Package id 0").
    Process {
        running: true
        command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do [ \"$(cat \"$h/name\")\" = coretemp ] && echo \"$h\" && exit; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const dir = text.trim();
                if (dir !== "") {
                    tempMaxFile.path = dir + "/temp1_max";
                    tempInput.path = dir + "/temp1_input";
                }
            }
        }
    }

    FileView {
        id: tempInput

        onLoaded: root.temp = Number(text()) / 1000
    }

    FileView {
        id: tempMaxFile

        onLoaded: {
            const max = Number(text()) / 1000;
            if (max > 0)
                root.tempMax = max;
        }
    }
}

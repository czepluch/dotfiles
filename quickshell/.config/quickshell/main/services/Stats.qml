pragma Singleton

// CPU, temperature, memory, disk, network and process readings from /proc
// and /sys while the session is active. CPU and temperature are read every
// 2 s and memory every 10 s. While `detailed` is set (the system panel is
// open), memory, load, fan speed, network traffic and the top processes are
// read every 2 s and disk use every 10 s.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool detailed: false

    // CPU usage from 0 to 1, smoothed over about 3 s for display.
    property real cpu: 0
    // Usage of each CPU from 0 to 1, by CPU number.
    property var cores: []
    // CPU numbers grouped by maximum clock, fastest group first.
    property var coreGroups: []
    // Load average over 1 minute.
    property real load: 0

    // Package temperature and the sensor's maximum, in °C.
    property real temp: 0
    property real tempMax: 100
    // Fan speed in rpm, or -1 without a fan sensor.
    property int fan: -1

    // Raw samples, oldest first, one per update: CPU usage from 0 to 1 and
    // temperature in °C.
    readonly property int historyLength: 60
    property var cpuHistory: []
    property var tempHistory: []

    // Memory in use from 0 to 1 (total minus available), and in bytes.
    property real mem: 0
    property real memUsed: 0
    property real memTotal: 0
    property real swapUsed: 0
    property real swapTotal: 0
    // Share of the last 10 s in which some task waited for memory, in %.
    property real memPressure: 0

    // Root file system, in bytes.
    property real diskUsed: 0
    property real diskTotal: 0

    // Traffic on physical network interfaces, in bytes per second.
    property real netDown: 0
    property real netUp: 0

    // The processes using the most CPU, as { name, cpu, mem }: CPU in % of
    // one CPU (as top shows it) and resident memory in bytes.
    property var processes: []

    // Elevated levels, shown in yellow, and critical levels, shown in red.
    readonly property real cpuWarnLevel: 0.7
    readonly property real tempWarnLevel: tempMax - 20
    readonly property real tempAlertLevel: tempMax - 10
    readonly property bool cpuWarn: cpu >= cpuWarnLevel
    readonly property bool tempWarn: temp >= tempWarnLevel
    readonly property bool tempAlert: temp >= tempAlertLevel
    readonly property bool memWarn: mem >= 0.8
    readonly property bool memAlert: memPressure >= 10
    readonly property bool diskWarn: diskTotal > 0 && diskUsed / diskTotal >= 0.9

    readonly property int interval: 2000
    property int tick: 0
    property var lastCpu: null
    property var netInterfaces: []
    property var lastNet: null

    // One "cpu" line of /proc/stat: "cpu user nice system idle iowait irq
    // softirq steal guest guest_nice". Guest time is already counted in
    // user. iowait counts as idle.
    function cpuTimes(line) {
        const fields = line.trim().split(/\s+/).slice(1, 9).map(Number);
        return { idle: fields[3] + fields[4], total: fields.reduce((a, b) => a + b, 0) };
    }

    function usage(now, last) {
        if (!last || now.total <= last.total)
            return null;
        return Math.min(1, Math.max(0, 1 - (now.idle - last.idle) / (now.total - last.total)));
    }

    function parseStat(text) {
        const times = text.split("\n").filter(line => line.startsWith("cpu")).map(cpuTimes);
        const all = usage(times[0], lastCpu?.[0]);
        if (all !== null) {
            cpuHistory = cpuHistory.concat([all]).slice(-historyLength);
            cpu = cpuHistory.length === 1 ? all : cpu + (1 - Math.exp(-interval / 3000)) * (all - cpu);
            cores = times.slice(1).map((t, i) => usage(t, lastCpu[i + 1]) ?? 0);
        }
        lastCpu = times;
    }

    function parseMeminfo(text) {
        const kib = name => Number(new RegExp(name + ":\\s+(\\d+)").exec(text)?.[1] ?? 0) * 1024;
        const total = kib("MemTotal");
        if (total > 0) {
            memTotal = total;
            memUsed = total - kib("MemAvailable");
            mem = memUsed / total;
        }
        swapTotal = kib("SwapTotal");
        swapUsed = swapTotal - kib("SwapFree");
    }

    // /proc/net/dev: "iface: rx_bytes rx_packets ... (8 receive fields)
    // tx_bytes ...", summed over the physical interfaces.
    function parseNetDev(text) {
        let down = 0;
        let up = 0;
        for (const line of text.split("\n")) {
            const colon = line.indexOf(":");
            if (colon < 0 || !netInterfaces.includes(line.slice(0, colon).trim()))
                continue;
            const fields = line.slice(colon + 1).trim().split(/\s+/).map(Number);
            down += fields[0];
            up += fields[8];
        }
        const now = Date.now();
        if (lastNet !== null && now > lastNet.time) {
            netDown = Math.max(0, (down - lastNet.down) * 1000 / (now - lastNet.time));
            netUp = Math.max(0, (up - lastNet.up) * 1000 / (now - lastNet.time));
        }
        lastNet = { down: down, up: up, time: now };
    }

    // A top memory value in MiB, with a g or t suffix when top scales it up.
    function topBytes(value) {
        const scale = { k: 1 / 1024, m: 1, g: 1024, t: 1024 * 1024 }[value.slice(-1)] ?? 1 / 1024;
        return parseFloat(value) * scale * 1024 * 1024;
    }

    onDetailedChanged: {
        if (!detailed)
            return;
        lastNet = null;
        netDown = 0;
        netUp = 0;
        interfaces.running = true;
        disk.running = true;
        topProcesses.running = true;
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
            if (root.detailed || root.tick % 5 === 0) {
                meminfo.reload();
                memoryPressure.reload();
            }
            if (root.detailed) {
                loadavg.reload();
                netDev.reload();
                if (fanInput.path !== "")
                    fanInput.reload();
                if (!topProcesses.running)
                    topProcesses.running = true;
                if (root.tick % 5 === 0)
                    disk.running = true;
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

    FileView {
        id: loadavg

        path: "/proc/loadavg"
        onLoaded: root.load = parseFloat(text())
    }

    FileView {
        id: netDev

        path: "/proc/net/dev"
        onLoaded: root.parseNetDev(text())
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

        onLoaded: {
            root.temp = Number(text()) / 1000;
            root.tempHistory = root.tempHistory.concat([root.temp]).slice(-root.historyLength);
        }
    }

    FileView {
        id: tempMaxFile

        onLoaded: {
            const max = Number(text()) / 1000;
            if (max > 0)
                root.tempMax = max;
        }
    }

    // Fan sensors as "name dir" lines. The ACPI fan device can report 0 rpm
    // while the fan runs, so other sensors come first.
    Process {
        running: true
        command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do [ -e \"$h/fan1_input\" ] && echo \"$(cat \"$h/name\") $h\"; done; true"]
        stdout: StdioCollector {
            onStreamFinished: {
                const sensors = text.split("\n").filter(line => line !== "").map(line => line.split(" "));
                const sensor = sensors.find(s => s[0] !== "acpi_fan") ?? sensors[0];
                if (sensor)
                    fanInput.path = sensor[1] + "/fan1_input";
            }
        }
    }

    FileView {
        id: fanInput

        onLoaded: root.fan = Number(text())
    }

    // CPU numbers with their maximum clock, grouped fastest first.
    Process {
        running: true
        command: ["sh", "-c", "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo \"${c##*cpu} $(cat \"$c/cpufreq/cpuinfo_max_freq\" 2>/dev/null || echo 0)\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const groups = new Map();
                text.split("\n").filter(line => line !== "").map(line => line.split(" ").map(Number))
                    .sort((a, b) => b[1] - a[1] || a[0] - b[0])
                    .forEach(([cpu, clock]) => groups.set(clock, (groups.get(clock) ?? []).concat([cpu])));
                root.coreGroups = Array.from(groups.values());
            }
        }
    }

    // Interfaces backed by a device, so loopback, VPN and bridge traffic is
    // not counted.
    Process {
        id: interfaces

        command: ["sh", "-c", "for i in /sys/class/net/*; do [ -e \"$i/device\" ] && basename \"$i\"; done; true"]
        stdout: StdioCollector {
            onStreamFinished: root.netInterfaces = text.split("\n").filter(line => line !== "")
        }
    }

    Process {
        id: disk

        command: ["df", "-B1", "--output=used,size", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("\n").pop().trim().split(/\s+/).map(Number);
                if (fields.length === 2 && fields[1] > 0) {
                    root.diskUsed = fields[0];
                    root.diskTotal = fields[1];
                }
            }
        }
    }

    // top's second sample covers the last second; its first covers the time
    // since each process started. Columns: PID USER PR NI VIRT RES SHR S
    // %CPU %MEM TIME+ COMMAND, where the command can contain spaces.
    Process {
        id: topProcesses

        command: ["sh", "-c", "LC_ALL=C top -b -n 2 -d 1 -e m -w 512 -o %CPU | awk '/^top -/ { n++ } n == 2 && found; n == 2 && /^ *PID/ { found = 1 }' | head -5"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.processes = text.split("\n").filter(line => line.trim() !== "").map(line => {
                    const fields = line.trim().split(/\s+/);
                    return { name: fields.slice(11).join(" "), cpu: Number(fields[8]), mem: root.topBytes(fields[5]) };
                });
            }
        }
    }
}

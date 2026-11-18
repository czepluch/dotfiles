pragma Singleton

// State and switching of the control panel toggles that live outside
// Quickshell: do-not-disturb (a mako mode), VPN (WireGuard links) and night
// light (sunsetr running). The VPN state follows link changes as they
// happen; do-not-disturb and night light are read every 30 s while the
// session is active, when it becomes active, and after each switch. Keep
// awake lives in Session, Bluetooth and microphone mute in their services.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool dnd: false
    // Names of WireGuard interfaces that are up.
    property var vpnLinks: []
    readonly property bool vpn: vpnLinks.length > 0
    property bool nightLight: false

    // Starting a query while it runs queues a single rerun.
    function refresh() {
        dndQuery.running = true;
        vpnQuery.running = true;
        nightLightQuery.running = true;
    }

    function toggleDnd() {
        dnd = !dnd;
        dndAction.running = true;
    }

    // Takes down every WireGuard link that is up, or brings up dappnode-remote.
    function toggleVpn() {
        const links = vpnLinks.filter(name => /^[\w.-]+$/.test(name));
        vpnAction.command = ["sh", "-c", vpn
            ? links.map(name => "sudo -n wg-quick down " + name).join(" && ")
            : "sudo -n wg-quick up dappnode-remote"];
        vpnAction.running = true;
    }

    function toggleNightLight() {
        nightLight = !nightLight;
        nightLightAction.command = nightLight ? ["sunsetr", "--background"] : ["sunsetr", "stop"];
        nightLightAction.running = true;
    }

    function warnOnFailure(name, exitCode) {
        if (exitCode !== 0)
            console.warn(name, "failed with exit code", exitCode);
    }

    Component.onCompleted: refresh()

    Connections {
        target: Session

        function onActiveChanged() {
            if (Session.active)
                root.refresh();
        }
    }

    Timer {
        interval: 30000
        running: Session.active
        repeat: true
        onTriggered: {
            dndQuery.running = true;
            nightLightQuery.running = true;
        }
    }

    Process {
        id: dndAction

        command: ["makoctl", "mode", "-t", "do-not-disturb"]
        onExited: exitCode => {
            root.warnOnFailure("Do not disturb", exitCode);
            dndQuery.running = true;
        }
    }

    Process {
        id: vpnAction

        onExited: exitCode => {
            root.warnOnFailure("VPN", exitCode);
            vpnQuery.running = true;
        }
    }

    // sunsetr --background returns before the new instance is up, so the
    // state is read again a moment later.
    Process {
        id: nightLightAction

        onExited: exitCode => {
            root.warnOnFailure("Night light", exitCode);
            nightLightRecheck.restart();
        }
    }

    Timer {
        id: nightLightRecheck

        interval: 1000
        onTriggered: nightLightQuery.running = true
    }

    Process {
        id: dndQuery

        command: ["makoctl", "mode"]
        stdout: StdioCollector {
            onStreamFinished: root.dnd = text.split("\n").includes("do-not-disturb")
        }
    }

    Process {
        id: vpnQuery

        command: ["sh", "-c", "for f in /sys/class/net/*/uevent; do grep -q '^DEVTYPE=wireguard$' \"$f\" && basename \"$(dirname \"$f\")\"; done; true"]
        stdout: StdioCollector {
            onStreamFinished: root.vpnLinks = text.split("\n").filter(line => line !== "")
        }
    }

    // Reports every link change, so the VPN state follows links that other
    // tools bring up or down.
    Process {
        running: true
        command: ["ip", "-o", "monitor", "link"]
        stdout: SplitParser {
            onRead: vpnQuery.running = true
        }
    }

    Process {
        id: nightLightQuery

        command: ["pgrep", "-x", "sunsetr"]
        onExited: exitCode => root.nightLight = exitCode === 0
    }
}

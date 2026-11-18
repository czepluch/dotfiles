pragma Singleton

// ETH price in USD and its 24-hour change, from the keyless CoinGecko API.
// Refreshed every minute while the session is active or locked. The last
// result survives config reloads, and a fetch is skipped when the last one
// is less than a minute old. When fetches fail the last price is kept and
// marked stale.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int interval: 60000
    readonly property real price: saved.price
    readonly property real change24h: saved.change24h
    readonly property bool available: !isNaN(price)
    // True while fetches fail.
    property bool stale: false

    // "$1,814"
    readonly property string priceText: available ? "$" + price.toLocaleString(Qt.locale("en_US"), "f", 0) : "…"
    // "▲ 2.1%" or "▼ 0.4%"
    readonly property string changeText: isNaN(change24h) ? ""
        : (change24h >= 0 ? "▲ " : "▼ ") + Math.abs(change24h).toFixed(1) + "%"

    function failed(reason) {
        if (!stale)
            console.warn("ETH price fetch failed:", reason);
        stale = true;
    }

    PersistentProperties {
        id: saved

        reloadableId: "eth"

        property real price: NaN
        property real change24h: NaN
        // Time of the last successful fetch, in ms since the epoch.
        property real updated: 0
    }

    Timer {
        interval: root.interval
        running: Session.active || Session.locked
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (Date.now() - saved.updated >= root.interval - 5000)
                fetch.running = true;
        }
    }

    Process {
        id: fetch

        command: ["curl", "-fsS", "--max-time", "10",
            "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd&include_24hr_change=true"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const eth = JSON.parse(text).ethereum;
                    if (typeof eth.usd !== "number")
                        throw new Error("no price in the response");
                    saved.price = eth.usd;
                    saved.change24h = eth.usd_24h_change ?? NaN;
                    saved.updated = Date.now();
                    root.stale = false;
                } catch (e) {
                    root.failed(e);
                }
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.failed("curl exit code " + exitCode);
        }
    }
}

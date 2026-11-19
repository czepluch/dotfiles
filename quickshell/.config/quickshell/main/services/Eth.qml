pragma Singleton

// ETH price in USD from the Chainlink ETH/USD feed on Ethereum mainnet, read
// through an Ethereum node's JSON-RPC: ETH_RPC_URL, or DappNode's mainnet
// execution client. The feed updates when the price moves enough, and at
// least once an hour; it is read every minute while the session is active
// or locked. The 24 h change compares with the newest feed update that is
// at least 24 h old, looked up again once an hour by reading back through
// past updates. The last results survive config reloads. When reads fail
// the last price is kept and marked stale. The direction of the last change
// of the shown price (whole dollars) is kept until the shown price changes
// again.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string rpcUrl: Quickshell.env("ETH_RPC_URL") || "http://execution.mainnet.dncore.dappnode:8545"
    // The ETH / USD proxy contract; answers have 8 decimals.
    readonly property string feed: "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419"
    readonly property string latestRoundData: "0xfeaf968c"
    readonly property string getRoundData: "0x9a6fc8f5"
    readonly property int interval: 60000
    readonly property int referenceInterval: 60 * 60000
    // Past updates read per request, and the most requests per lookup.
    readonly property int batchSize: 50
    readonly property int maxBatches: 6

    readonly property real price: saved.price
    readonly property real change24h: isNaN(saved.referencePrice) || isNaN(price) ? NaN
        : (price - saved.referencePrice) / saved.referencePrice * 100
    readonly property bool available: !isNaN(price)
    // 1 when the shown price last went up, -1 when it went down, 0 before
    // the first change.
    readonly property int direction: saved.direction
    // True while reads fail.
    property bool stale: false

    // "$1,814"
    readonly property string priceText: available ? "$" + price.toLocaleString(Qt.locale("en_US"), "f", 0) : "…"
    // "▲ 2.1%" or "▼ 0.4%"
    readonly property string changeText: isNaN(change24h) ? ""
        : (change24h >= 0 ? "▲ " : "▼ ") + Math.abs(change24h).toFixed(1) + "%"

    function failed(reason) {
        if (!stale)
            console.warn("ETH price read failed:", reason);
        stale = true;
    }

    function request(calls) {
        return ["curl", "-fsS", "--max-time", "10", "-H", "Content-Type: application/json",
            "-d", JSON.stringify(calls), rpcUrl];
    }

    function call(id, data) {
        return { jsonrpc: "2.0", id: id, method: "eth_call", params: [{ to: feed, data: data }, "latest"] };
    }

    // Round data as returned by latestRoundData and getRoundData: five
    // 32-byte words (roundId, answer, startedAt, updatedAt, answeredInRound).
    // A round ID is the phase in the bits above 64 and the aggregator's own
    // round number below, which fits in a double; the phase part is kept as
    // hex, since the whole ID does not.
    function parseRound(result) {
        if (typeof result !== "string" || result.length < 2 + 5 * 64)
            return null;
        const word = i => result.slice(2 + 64 * i, 2 + 64 * (i + 1));
        const answer = word(1);
        if (parseInt(answer[0], 16) >= 8)
            return null;
        return {
            phase: word(0).slice(0, 48),
            round: parseInt(word(0).slice(48), 16),
            price: parseInt(answer, 16) / 1e8,
            updatedAt: parseInt(word(3), 16)
        };
    }

    function roundId(phase, round) {
        return phase + round.toString(16).padStart(16, "0");
    }

    // Reads past updates from the latest backwards, batchSize at a time.
    function lookUpReference(batch) {
        const first = saved.round - batch * batchSize - 1;
        const calls = [];
        for (let back = 0; back < batchSize && first - back >= 1; back++)
            calls.push(call(back, getRoundData + roundId(saved.phase, first - back)));
        if (calls.length === 0)
            return;
        reference.batch = batch;
        reference.command = request(calls);
        reference.running = true;
    }

    PersistentProperties {
        id: saved

        reloadableId: "eth"

        property real price: NaN
        property int direction: 0
        // The latest feed update's round, as phase hex and round number.
        property string phase: ""
        property int round: 0
        // Time of the last successful read, in ms since the epoch.
        property real updated: 0
        property real referencePrice: NaN
        property real referenceChecked: 0
    }

    Timer {
        interval: root.interval
        running: Session.active || Session.locked
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (Date.now() - saved.updated >= root.interval - 5000)
                latest.running = true;
        }
    }

    Process {
        id: latest

        command: root.request([root.call(0, root.latestRoundData)])
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const latestRound = root.parseRound(JSON.parse(text)[0]?.result);
                    if (latestRound === null)
                        throw new Error("no round data in the response");
                    const shown = Math.round(latestRound.price);
                    if (!isNaN(saved.price) && shown !== Math.round(saved.price))
                        saved.direction = shown > Math.round(saved.price) ? 1 : -1;
                    saved.price = latestRound.price;
                    saved.phase = latestRound.phase;
                    saved.round = latestRound.round;
                    saved.updated = Date.now();
                    root.stale = false;
                    if (Date.now() - saved.referenceChecked >= root.referenceInterval && !reference.running)
                        root.lookUpReference(0);
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

    // Finds the newest update at least 24 h old in one batch of past
    // updates, or reads the next batch once this request has exited.
    Process {
        id: reference

        property int batch: 0
        // The batch to read next, or -1.
        property int next: -1

        stdout: StdioCollector {
            onStreamFinished: {
                reference.next = -1;
                try {
                    const dayAgo = Date.now() / 1000 - 86400;
                    const rounds = JSON.parse(text).map(response => root.parseRound(response.result)).filter(r => r !== null);
                    const old = rounds.filter(r => r.updatedAt <= dayAgo).sort((a, b) => b.updatedAt - a.updatedAt)[0];
                    if (old) {
                        saved.referencePrice = old.price;
                        saved.referenceChecked = Date.now();
                    } else if (rounds.length > 0 && reference.batch + 1 < root.maxBatches) {
                        reference.next = reference.batch + 1;
                    } else {
                        throw new Error("no update older than 24 h in " + root.maxBatches * root.batchSize + " rounds");
                    }
                } catch (e) {
                    console.warn("ETH 24 h reference lookup failed:", e);
                    saved.referenceChecked = Date.now();
                }
            }
        }
        onExited: {
            if (next >= 0)
                root.lookUpReference(next);
        }
    }
}

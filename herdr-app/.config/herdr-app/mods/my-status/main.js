import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, theme, run, window, keys, checking, home, readTextFile } from "herdr";

// Chainlink ETH/USD price feed on Ethereum mainnet, read through the DappNode
// execution client. latestRoundData() returns 5 words; word 1 is the price
// with 8 decimals.
const RPC_URL = "http://execution.mainnet.dncore.dappnode:8545";
const ETH_USD_FEED = "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419";
const LATEST_ROUND_DATA = "0xfeaf968c";
const PRICE_DECIMALS = 8;
const POLL_MS = 60000;

// Claude plan usage limits, saved by ~/.claude/statusline.sh from the status
// line input's `rate_limits` (5-hour and 7-day windows, each with
// used_percentage and resets_at in epoch seconds).
const LIMITS_FILE = ".cache/claude-statusline/rate-limits.json";
const LIMITS_POLL_MS = 20000;
const LIMIT_WINDOWS = [["5h", "five_hour", "5-hour"], ["7d", "seven_day", "7-day"]];

// "2h 10m", "5d 3h", "4m".
const until = (seconds) => {
  const m = Math.max(0, Math.round(seconds / 60));
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h ${m % 60}m` : `${Math.floor(h / 24)}d ${h % 24}h`;
};

export default class WorkspaceStatus extends View {
  init(_props, cx) {
    this.ethPrice = null;
    this.ethFailed = false;
    this.limits = null;
    if (checking()) return;
    cx.timer.every(POLL_MS, (cx) => this.loadEthPrice(cx));
    this.loadEthPrice(cx);
    cx.timer.every(LIMITS_POLL_MS, (cx) => this.loadLimits(cx));
    this.loadLimits(cx);
  }

  loadLimits(cx) {
    cx.spawn(async (cx) => {
      try {
        const text = await readTextFile(`${home()}/${LIMITS_FILE}`);
        this.limits = text ? JSON.parse(text) : null;
      } catch (e) {
        console.log(`claude limits: ${e}`);
        this.limits = null;
      }
      cx.notify();
    });
  }

  // "5h 42%  7d 16%": windows that haven't reset yet, yellow from 70%, red from 90%.
  limitsLabel(t) {
    const now = Date.now() / 1000;
    const shown = LIMIT_WINDOWS
      .map(([short, key, long]) => [short, long, this.limits?.[key]])
      .filter(([, , w]) => w && Number.isFinite(w.used_percentage) && w.resets_at > now);
    if (!shown.length) return null;
    const color = (p) => (p >= 90 ? t.blocked : p >= 70 ? t.ansi3 : t.muted);
    const tip = shown.map(([, long, w]) => `${long} limit: ${Math.round(w.used_percentage)}% used, resets in ${until(w.resets_at - now)}`).join(" · ");
    return h_flex().id("claude-limits").gap(8).items_center().tooltip(tip)
      .children(shown.map(([short, , w]) => div().text_color(color(w.used_percentage)).child(`${short} ${Math.round(w.used_percentage)}%`)));
  }

  loadEthPrice(cx) {
    cx.spawn(async (cx) => {
      try {
        const res = await fetch(RPC_URL, {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({
            jsonrpc: "2.0",
            id: 1,
            method: "eth_call",
            params: [{ to: ETH_USD_FEED, data: LATEST_ROUND_DATA }, "latest"],
          }),
        });
        const { result } = await res.json();
        const answer = parseInt(result.slice(2 + 64, 2 + 128), 16);
        if (!Number.isFinite(answer) || answer <= 0) throw new Error(`bad answer: ${result}`);
        this.ethPrice = answer / 10 ** PRICE_DECIMALS;
        this.ethFailed = false;
      } catch (e) {
        console.log(`eth price: ${e}`);
        this.ethFailed = true;
      }
      cx.notify();
    });
  }

  // Whole dollars with thousands separators; dimmed after a failed fetch.
  ethLabel(t) {
    const dollars = Math.round(this.ethPrice).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return div().when(this.ethFailed, (el) => el.text_color(t.dim)).child(`ETH $${dollars}`);
  }

  // The palette key as actually bound, not a hardcoded one; without a
  // binding the hint stays useful ("commands") instead of lying.
  hint(t) {
    const mac = window()?.platform === "macos";
    const mod = { cmd: mac ? "⌘" : "Ctrl+", ctrl: mac ? "⌃" : "Ctrl+", shift: mac ? "⇧" : "Shift+", alt: mac ? "⌥" : "Alt+", option: mac ? "⌥" : "Alt+" };
    const b = keys().find((k) => k.section === "global" && k.action === "app.palette");
    const parts = b && b.keys.endsWith("--") ? [...b.keys.slice(0, -2).split("-"), "-"] : b?.keys.split("-");
    const key = parts && parts.map((p) => mod[p.toLowerCase()] ?? p.toUpperCase()).join("");
    return key ? `${key}  commands` : "commands";
  }

  render() {
    const t = theme();
    const space = spaces().find(s => s.active);
    const list = agents();
    const needs = list.filter(a => a.status === "blocked").length;
    const label = (icon, text) => h_flex().gap(6).items_center().child(svg(`mods/workspace-chrome/${icon}.svg`).size(13)).child(text);
    return h_flex().size_full().px(14).gap(16).items_center().bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8).text_color(t.muted)
      .child(label(space?.machine ? "server" : "monitor", space?.machine ?? "This computer"))
      .when(Boolean(space?.branch), el => el.child(label("branch", space.branch)))
      .child(h_flex().gap(6).items_center().child(div().size(6).rounded(3).bg(t.dim)).child(`${list.length} agents`)
        .when(needs > 0, el => el.child(div().text_color(t.blocked).child(`· ${needs} needs you`))))
      .when(this.ethPrice != null, el => el.child(this.ethLabel(t)))
      .when(Boolean(this.limitsLabel(t)), el => el.child(this.limitsLabel(t)))
      .child(div().flex_1())
      .child(div().id("palette").text_color(t.dim).on_click(() => run("app.palette")).child(this.hint(t)));
  }
}

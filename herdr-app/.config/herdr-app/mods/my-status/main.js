import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, theme, run, window, keys, checking } from "herdr";

// Chainlink ETH/USD price feed on Ethereum mainnet, read through the DappNode
// execution client. latestRoundData() returns 5 words; word 1 is the price
// with 8 decimals.
const RPC_URL = "http://execution.mainnet.dncore.dappnode:8545";
const ETH_USD_FEED = "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419";
const LATEST_ROUND_DATA = "0xfeaf968c";
const PRICE_DECIMALS = 8;
const POLL_MS = 60000;

export default class WorkspaceStatus extends View {
  init(_props, cx) {
    this.ethPrice = null;
    this.ethFailed = false;
    if (checking()) return;
    cx.timer.every(POLL_MS, (cx) => this.loadEthPrice(cx));
    this.loadEthPrice(cx);
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
      .child(div().flex_1())
      .child(div().id("palette").text_color(t.dim).on_click(() => run("app.palette")).child(this.hint(t)));
  }
}

// Hands each notification to the system notification service with notify-send
// (app name "Herdr") and closes Herdr's own pop-up at once. A detached shell
// waits for the click and runs the notification's action (e.g. going to the
// agent) with `herdr-app do`, since this mod is gone by then.

import { View, div } from "gpui-kit";
import { props, closeOverlay, exec, checking } from "herdr";

const URGENCY = { error: "critical" };

// $1: the action's command, $2: its arguments as JSON, the rest: notify-send's arguments.
const WAIT_AND_RUN = 'name=$1; args=$2; shift 2; [ "$(notify-send "$@")" = default ] && [ -n "$name" ] && exec herdr-app do "$name" "$args"';

export default class Toast extends View {
  init(_props, _cx) {
    const p = props() ?? {};
    if (p.overlay) closeOverlay(p.overlay);
    if (checking()) return;
    const args = ["--app-name=Herdr", `--urgency=${URGENCY[p.level] ?? "normal"}`];
    if (p.timeout) args.push(`--expire-time=${p.timeout}`);
    if (p.icon?.startsWith("/")) args.push(`--icon=${p.icon}`);
    if (p.action?.name) args.push("--action=default=Open");
    args.push(p.title || "Herdr", p.body ?? "");
    const action = p.action?.name ?? "";
    exec("setsid", ["-f", "sh", "-c", WAIT_AND_RUN, "herdr-notify", action, JSON.stringify(p.action?.args ?? {}), ...args])
      .catch((e) => console.log(`notify-send: ${e}`));
  }

  render() {
    return div();
  }
}

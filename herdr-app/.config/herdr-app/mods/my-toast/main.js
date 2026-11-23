// Hands each notification to the system notification service with notify-send
// (app name "Herdr") and closes Herdr's own pop-up at once. A detached shell
// waits for the click and runs the notification's action (e.g. going to the
// agent) with `herdr-app do`, since this mod is gone by then. A notification
// with the same action (the same agent) as an earlier one closes that one and
// ends its shell, so each agent has at most one notification.

import { View, div } from "gpui-kit";
import { props, closeOverlay, exec, checking } from "herdr";

const URGENCY = { error: "critical" };

// $1: the action's command, $2: its arguments as JSON, $3: a file name for the
// action ("" for none), the rest: notify-send's arguments. The file in
// $XDG_RUNTIME_DIR/herdr-notify holds the shown notification's id and the
// waiting shell's process group (setsid makes it the shell's own id).
const WAIT_AND_RUN = `
name=$1; args=$2; key=$3; shift 3
f=
if [ -n "$key" ]; then
  dir="\${XDG_RUNTIME_DIR:-/tmp}/herdr-notify"
  mkdir -p "$dir"
  f="$dir/$key"
  if [ -f "$f" ] && read -r old group < "$f"; then
    gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications \
      --method org.freedesktop.Notifications.CloseNotification "$old" >/dev/null 2>&1
    kill -- "-$group" 2>/dev/null
  fi
fi
notify-send --print-id "$@" | {
  read -r id
  [ -n "$f" ] && echo "$id $$" > "$f"
  read -r act
  [ -n "$f" ] && [ "$(cat "$f" 2>/dev/null)" = "$id $$" ] && rm -f "$f"
  [ "$act" = default ] && [ -n "$name" ] && exec herdr-app do "$name" "$args"
}`;

// A file name for an action: its command and arguments with only safe characters.
const actionKey = (action) =>
  action?.name ? `${action.name}-${JSON.stringify(action.args ?? {})}`.replace(/[^A-Za-z0-9._-]+/g, "_").slice(0, 200) : "";

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
    exec("setsid", ["-f", "sh", "-c", WAIT_AND_RUN, "herdr-notify", action, JSON.stringify(p.action?.args ?? {}), actionKey(p.action), ...args])
      .catch((e) => console.log(`notify-send: ${e}`));
  }

  render() {
    return div();
  }
}

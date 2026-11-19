pragma Singleton
pragma ComponentBehavior: Bound

// Desktop notifications: the shell is the notification server
// (org.freedesktop.Notifications). Every notification stays in `list`,
// newest first, until it is dismissed, its app closes it or the shell
// restarts. A new one, or one its app updates, also pops up: `popups`,
// newest first, at most 3, older ones only leave the popups. Nothing pops
// up during do-not-disturb, except a critical one, or while a dashboard
// shows the list. A popup leaves after the app's timeout, or 5 s when the
// app sets none, counted only while the popups are not paused (the mouse is
// over them); a critical one, or one the app sets to never expire, stays
// until it is dismissed. A transient one is closed when its popup leaves.
//
// qs -c main ipc call notifications toggleDnd
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    property alias dnd: persist.dnd
    // Set while a dashboard is open (see Bar).
    property bool listOpen: false
    // Set while the mouse is over the popups (see Bar).
    property bool paused: false
    readonly property int maxPopups: 3
    readonly property int defaultTimeout: 5000
    readonly property var list: Array.from(server.trackedNotifications.values).reverse()
    // The popups as { notification, left }, newest first: left is the time
    // in ms until it leaves, or -1 for never.
    property var entries: []
    readonly property var popups: entries.map(entry => entry.notification).filter(n => list.includes(n))
    // Notification id -> the time it arrived or was last updated.
    readonly property var received: JSON.parse(persist.received)

    // Runs the default action, which dismisses it unless the app keeps it;
    // without a default action, dismisses it.
    function activate(notification) {
        const action = notification.actions.find(a => a.identifier === "default");
        if (action)
            action.invoke();
        else
            notification.dismiss();
    }

    function dismiss(notification) {
        notification.dismiss();
    }

    function clear() {
        for (const notification of list)
            notification.dismiss();
    }

    // The time it arrived or was last updated, in ms since the epoch.
    function timeOf(notification) {
        return received[notification.id] ?? 0;
    }

    function show(notification) {
        const now = Date.now();
        const times = {};
        for (const n of list)
            times[n.id] = received[n.id] ?? now;
        times[notification.id] = now;
        persist.received = JSON.stringify(times);

        const critical = notification.urgency === NotificationUrgency.Critical;
        if (listOpen || (dnd && !critical)) {
            if (!entries.some(entry => entry.notification === notification))
                leave(notification);
            return;
        }
        const timeout = notification.expireTimeout;
        const left = critical || timeout === 0 ? -1 : timeout > 0 ? timeout : defaultTimeout;
        const others = entries.filter(entry => entry.notification !== notification && list.includes(entry.notification));
        entries = [{ notification: notification, left: left }].concat(others.slice(0, maxPopups - 1));
        for (const entry of others.slice(maxPopups - 1))
            leave(entry.notification);
    }

    // Called when a notification stops being a popup, or is not shown as one.
    function leave(notification) {
        if (notification.transient)
            notification.expire();
    }

    function clearPopups() {
        const old = entries;
        entries = [];
        for (const entry of old)
            leave(entry.notification);
    }

    onListOpenChanged: {
        if (listOpen)
            clearPopups();
    }

    PersistentProperties {
        id: persist

        reloadableId: "notifications"

        property bool dnd: false
        // The times in `received` as JSON text; a JavaScript object does not
        // survive a reload.
        property string received: "{}"
    }

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        persistenceSupported: true

        // After a reload the server announces the notifications it kept
        // again; those keep their time and do not pop up again.
        onNotification: notification => {
            notification.tracked = true;
            if (!notification.lastGeneration)
                root.show(notification);
        }
    }

    // A notification that its app updates pops up again.
    Instantiator {
        model: server.trackedNotifications

        delegate: Connections {
            required property Notification modelData

            target: modelData

            function onSummaryChanged() {
                root.show(modelData);
            }

            function onBodyChanged() {
                root.show(modelData);
            }
        }
    }

    // Counts down the popups' time while they are not paused.
    Timer {
        id: countdown

        property real last: 0

        interval: 100
        repeat: true
        running: !root.paused && root.entries.some(entry => entry.left > 0)
        onRunningChanged: last = Date.now()
        onTriggered: {
            const now = Date.now();
            const elapsed = now - last;
            last = now;
            const kept = [];
            const gone = [];
            for (const entry of root.entries) {
                if (entry.left > 0)
                    entry.left = Math.max(0, entry.left - elapsed);
                if (entry.left === -1 || entry.left > 0)
                    kept.push(entry);
                else
                    gone.push(entry);
            }
            if (gone.length === 0)
                return;
            root.entries = kept;
            for (const entry of gone)
                root.leave(entry.notification);
        }
    }

    IpcHandler {
        target: "notifications"

        function toggleDnd(): void {
            root.dnd = !root.dnd;
        }
    }
}

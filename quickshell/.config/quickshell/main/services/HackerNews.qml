pragma Singleton

// The top 10 Hacker News stories, refreshed every hour while the session is
// active. The stories survive config reloads, and a fetch is skipped when
// the last one is less than an hour old and stories are present. One story is current at a time,
// changing every 10 minutes.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int interval: 60 * 60000
    readonly property int rotationMinutes: 10
    // Stories as { id, title, url, score, comments, by }, in ranking order.
    readonly property var stories: {
        try {
            return JSON.parse(saved.stories);
        } catch (e) {
            return [];
        }
    }
    property int index: 0
    readonly property var current: stories.length > 0 ? stories[index % stories.length] : null

    function open(story) {
        Quickshell.execDetached(["xdg-open", story.url]);
    }

    function openDiscussion(story) {
        Quickshell.execDetached(["xdg-open", discussionUrl(story)]);
    }

    function discussionUrl(story) {
        return "https://news.ycombinator.com/item?id=" + story.id;
    }

    function updateIndex() {
        index = Math.floor(Date.now() / (rotationMinutes * 60000));
    }

    Component.onCompleted: updateIndex()

    PersistentProperties {
        id: saved

        reloadableId: "hackernews"

        // JSON text: script values cannot be kept across reloads.
        property string stories: "[]"
        // Time of the last successful fetch, in ms since the epoch.
        property real updated: 0
    }

    Timer {
        interval: root.interval
        running: Session.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.stories.length === 0 || Date.now() - saved.updated >= root.interval - 60000)
                fetch.running = true;
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.updateIndex()
    }

    // Top story ids, then the ten stories in ranking order, one JSON object per line.
    Process {
        id: fetch

        command: ["sh", "-c",
            "ids=$(curl -fsS --max-time 5 https://hacker-news.firebaseio.com/v0/topstories.json | jq -r '.[0:10][]')"
            + " && for id in $ids; do"
            + " curl -fsS --max-time 5 \"https://hacker-news.firebaseio.com/v0/item/$id.json\""
            + " | jq -c '{id, title, url, score, comments: .descendants, by}';"
            + " done"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const stories = text.split("\n").filter(line => line !== "").map(line => {
                        const story = JSON.parse(line);
                        story.url = story.url ?? root.discussionUrl(story);
                        return story;
                    });
                    if (stories.length > 0) {
                        saved.stories = JSON.stringify(stories);
                        saved.updated = Date.now();
                    }
                } catch (e) {
                    console.warn("Hacker News fetch failed:", e);
                }
            }
        }
    }
}

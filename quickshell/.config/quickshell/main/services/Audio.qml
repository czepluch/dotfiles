pragma Singleton

// Default audio output and microphone from PipeWire.
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool micMuted: source?.audio?.muted ?? false

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property int percent: Math.round(volume * 100)
    readonly property string icon: muted ? "󰝟"
        : volume < 0.34 ? "󰕿"
        : volume < 0.67 ? "󰖀"
        : "󰕾"

    // Changes the volume by step (a fraction of full volume), within 0 to 1.
    function changeVolume(step) {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + step));
    }

    // Sets the volume from 0 to 1; a volume above 0 also unmutes.
    function setVolume(v) {
        if (!sink?.audio)
            return;
        sink.audio.volume = Math.max(0, Math.min(1, v));
        if (v > 0 && sink.audio.muted)
            sink.audio.muted = false;
    }

    function toggleMute() {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function toggleMic() {
        if (source?.audio)
            source.audio.muted = !source.audio.muted;
    }

    // Binds the nodes so their audio properties are filled in.
    PwObjectTracker {
        objects: [root.sink, root.source].filter(node => node !== null)
    }
}

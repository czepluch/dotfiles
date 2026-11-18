pragma Singleton

// Default audio output and microphone from PipeWire. A Bluetooth output
// gets an icon for its kind of device (headphones, headset, ...) and the
// headset icon while a call profile with the microphone is active.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool micMuted: source?.audio?.muted ?? false

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property int percent: Math.round(volume * 100)

    // WirePlumber names Bluetooth outputs "bluez_output.…".
    readonly property bool bluetooth: (sink?.name ?? "").startsWith("bluez_output")
    // The Bluetooth profiles that carry the microphone, used for calls.
    readonly property bool handsFree: bluetooth
        && ["headset-head-unit", "bap-duplex"].includes(sink?.properties?.["api.bluez5.profile"] ?? "")
    // The output's device, whose form factor (headphone, headset, ...) is
    // set on the device rather than on the node.
    readonly property string deviceId: bluetooth ? (sink?.properties?.["device.id"] ?? "") : ""
    property string formFactor: ""
    readonly property var formFactorIcons: ({
        "headphone": "󰋋",
        "headset": "󰋎",
        "hands-free": "󰋎",
        "handset": "󰏲",
        "portable": "󰦢",
        "speaker": "󰓃"
    })
    // A Bluetooth output keeps its device icon while muted, so it stays
    // visible which output is in use.
    readonly property string icon: bluetooth ? (handsFree ? "󰋎" : formFactorIcons[formFactor] ?? "󰂰")
        : muted ? "󰝟"
        : volume < 0.34 ? "󰕿"
        : volume < 0.67 ? "󰖀"
        : "󰕾"

    // The command is set here rather than bound, because a change handler
    // can run before bindings on the same property are updated.
    onDeviceIdChanged: {
        formFactor = "";
        if (deviceId === "")
            return;
        deviceInfo.command = ["wpctl", "inspect", deviceId];
        deviceInfo.running = true;
    }

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

    // Reads the form factor from "  * device.form-factor = \"headphone\"".
    Process {
        id: deviceInfo

        stdout: StdioCollector {
            onStreamFinished: root.formFactor = /device\.form-factor = "([^"]+)"/.exec(text)?.[1] ?? ""
        }
    }

    // Binds the nodes so their audio properties are filled in.
    PwObjectTracker {
        objects: [root.sink, root.source].filter(node => node !== null)
    }
}

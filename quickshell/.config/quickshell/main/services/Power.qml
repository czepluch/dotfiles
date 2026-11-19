pragma Singleton

// Power profile from power-profiles-daemon, with an icon and name for each,
// the profiles this machine offers, and cycling in the order saver,
// balanced, performance.
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property int profile: PowerProfiles.profile
    readonly property string icon: iconFor(profile)
    readonly property bool saver: profile === PowerProfile.PowerSaver
    readonly property bool performance: profile === PowerProfile.Performance
    readonly property list<int> profiles: PowerProfiles.hasPerformanceProfile
        ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
        : [PowerProfile.PowerSaver, PowerProfile.Balanced]

    function iconFor(p) {
        return p === PowerProfile.Performance ? "󰓅" : p === PowerProfile.PowerSaver ? "󰌪" : "󰾅";
    }

    function nameFor(p) {
        return p === PowerProfile.Performance ? "Performance" : p === PowerProfile.PowerSaver ? "Saver" : "Balanced";
    }

    function set(p) {
        PowerProfiles.profile = p;
    }

    function cycle() {
        set(profiles[(profiles.indexOf(profile) + 1) % profiles.length]);
    }
}

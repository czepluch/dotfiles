// The window of the launcher (see LauncherPanel), centered on the screen
// with Hyprland's focused monitor. It covers the screen on the overlay
// layer, so the panel shows above full-screen windows and the surface never
// resizes (a resize ends the focus grab), but it takes clicks only on the
// panel. A click outside the panel closes it.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    visible: Launcher.mode !== ""
    screen: Launcher.screen
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    mask: Region {
        item: panel
    }

    // Closes it on a click outside the panel, and gives it the keyboard.
    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
        onCleared: Launcher.cancel()
    }

    LauncherPanel {
        id: panel

        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
    }
}

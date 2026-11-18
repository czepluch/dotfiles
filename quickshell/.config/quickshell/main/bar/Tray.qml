pragma ComponentBehavior: Bound

// System tray icons. Left click activates an item, middle click runs its
// secondary action, right click opens its menu, scrolling is passed on.
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.components

Row {
    id: root

    // The bar window, used as the parent of tray menus.
    required property QsWindow window

    topPadding: Style.buttonInset
    bottomPadding: Style.buttonInset
    spacing: Style.buttonInset

    Repeater {
        model: SystemTray.items

        Clickable {
            id: trayItem

            required property SystemTrayItem modelData
            // A themed icon that the icon theme lacks (such as an
            // "-attention-symbolic" variant) falls back to the base name.
            readonly property string iconSource: {
                const source = modelData.icon;
                const prefix = "image://icon/";
                if (!source.startsWith(prefix))
                    return source;
                const name = source.slice(prefix.length).split("?")[0];
                if (Quickshell.hasThemeIcon(name))
                    return source;
                const base = name.replace(/-(attention|symbolic|panel)/g, "");
                return Quickshell.iconPath(base, "application-x-executable");
            }

            implicitWidth: Style.buttonSize
            implicitHeight: Style.buttonSize
            wheelEnabled: true
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton && !modelData.onlyMenu) {
                    modelData.activate();
                } else if (mouse.button === Qt.MiddleButton) {
                    modelData.secondaryActivate();
                } else if (modelData.hasMenu) {
                    const pos = trayItem.mapToItem(null, 0, trayItem.height);
                    modelData.display(root.window, pos.x, pos.y);
                }
            }
            onStepped: direction => modelData.scroll(direction * Style.wheelNotch, false)

            IconImage {
                anchors.centerIn: parent
                implicitSize: Style.iconSize
                source: trayItem.iconSource
            }
        }
    }
}

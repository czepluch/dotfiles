// Turns wheel movement into steps: one per notch. Smaller touchpad movements
// add up until they make a notch. Scrolling up (or left) gives +1.
import QtQuick
import qs

WheelHandler {
    id: root

    property real accumulated: 0

    signal stepped(int direction)

    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

    onWheel: event => {
        const delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x;
        if (delta === 0)
            return;
        accumulated += delta;
        while (Math.abs(accumulated) >= Style.wheelNotch) {
            const direction = accumulated > 0 ? 1 : -1;
            accumulated -= direction * Style.wheelNotch;
            root.stepped(direction);
        }
    }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_intervalSeconds: interval.value
    property alias cfg_movePixels: distance.value

    Controls.SpinBox {
        id: interval
        Kirigami.FormData.label: "Movement interval:"
        from: 5
        to: 3600
        stepSize: 5
        editable: true
        textFromValue: function(value) { return value + " seconds" }
        valueFromText: function(text) {
            const parsed = parseInt(text)
            return isNaN(parsed) ? 60 : parsed
        }
    }

    Controls.SpinBox {
        id: distance
        Kirigami.FormData.label: "Movement distance:"
        from: 1
        to: 50
        editable: true
        textFromValue: function(value) { return value + (value === 1 ? " pixel" : " pixels") }
        valueFromText: function(text) {
            const parsed = parseInt(text)
            return isNaN(parsed) ? 1 : parsed
        }
    }

    Controls.Label {
        Kirigami.FormData.isSection: true
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: "On Wayland, Move Mouse uses ydotool to generate genuine pointer input through Linux uinput."
    }
}

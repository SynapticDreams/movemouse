import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_showStatus: showStatus.checked
    property alias cfg_showCountdown: showCountdown.checked
    property alias cfg_animateMouse: animateMouse.checked
    property alias cfg_ringThickness: ringThickness.value

    Controls.Label {
        Kirigami.FormData.isSection: true
        text: "Mouse control"
        font.bold: true
    }

    Controls.CheckBox {
        id: showStatus
        Kirigami.FormData.label: "Status:"
        text: "Show Idle / Running / Blackout status"
    }

    Controls.CheckBox {
        id: showCountdown
        Kirigami.FormData.label: "Countdown:"
        text: "Show the circular countdown ring"
    }

    Controls.CheckBox {
        id: animateMouse
        Kirigami.FormData.label: "Animation:"
        text: "Animate state changes and execution"
    }

    Controls.SpinBox {
        id: ringThickness
        Kirigami.FormData.label: "Ring thickness:"
        from: 4
        to: 20
        enabled: showCountdown.checked
        textFromValue: function(value) { return value + " px" }
        valueFromText: function(text) {
            const parsed = parseInt(text)
            return isNaN(parsed) ? 10 : parsed
        }
    }

    Controls.Label {
        Kirigami.FormData.isSection: true
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: "The circular control deliberately follows the original Windows Move Mouse design: mascot in the centre, coloured state ring and click-to-start behaviour."
    }
}

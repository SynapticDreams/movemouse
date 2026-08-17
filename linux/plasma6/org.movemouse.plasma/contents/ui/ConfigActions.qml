import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_moveEnabled: moveEnabled.checked
    property alias cfg_movePixels: distance.value
    property alias cfg_moveDirection: direction.currentIndex
    property alias cfg_clickEnabled: clickEnabled.checked
    property alias cfg_clickButton: clickButton.currentIndex

    Controls.Label {
        Kirigami.FormData.isSection: true
        text: "Move Mouse Cursor"
        font.bold: true
    }

    Controls.CheckBox {
        id: moveEnabled
        Kirigami.FormData.label: "Enabled:"
        text: "Move the pointer each cycle"
    }

    Controls.SpinBox {
        id: distance
        Kirigami.FormData.label: "Distance:"
        from: 1
        to: 250
        editable: true
        enabled: moveEnabled.checked
        textFromValue: function(value) { return value + (value === 1 ? " pixel" : " pixels") }
        valueFromText: function(text) {
            const parsed = parseInt(text)
            return isNaN(parsed) ? 10 : parsed
        }
    }

    Controls.ComboBox {
        id: direction
        Kirigami.FormData.label: "Direction:"
        enabled: moveEnabled.checked
        model: ["Horizontal", "Vertical", "Diagonal", "Square", "Random"]
    }

    Controls.Label {
        Kirigami.FormData.isSection: true
        text: "Click Mouse Button"
        font.bold: true
    }

    Controls.CheckBox {
        id: clickEnabled
        Kirigami.FormData.label: "Enabled:"
        text: "Click after the movement action"
    }

    Controls.ComboBox {
        id: clickButton
        Kirigami.FormData.label: "Button:"
        enabled: clickEnabled.checked
        model: ["Left", "Right", "Middle"]
    }

    Controls.Label {
        Kirigami.FormData.isSection: true
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: "The Linux edition uses ydotool so these actions work in a KDE Plasma Wayland session as real input events."
    }
}

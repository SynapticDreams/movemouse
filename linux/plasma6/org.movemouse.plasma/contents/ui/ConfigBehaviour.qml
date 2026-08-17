import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_lowerInterval: lower.value
    property alias cfg_upperInterval: upper.value
    property alias cfg_randomInterval: random.checked
    property alias cfg_startAtLaunch: startAtLaunch.checked

    Controls.Label {
        Kirigami.FormData.isSection: true
        text: "Repeat actions"
        font.bold: true
    }

    Controls.CheckBox {
        id: random
        Kirigami.FormData.label: "Timing:"
        text: "Use a random interval"
    }

    Controls.SpinBox {
        id: lower
        Kirigami.FormData.label: random.checked ? "Minimum:" : "Every:"
        from: 1
        to: 3600
        editable: true
        textFromValue: function(value) { return value + " seconds" }
        valueFromText: function(text) {
            const parsed = parseInt(text)
            return isNaN(parsed) ? 30 : parsed
        }
        onValueModified: if (value > upper.value) upper.value = value
    }

    Controls.SpinBox {
        id: upper
        Kirigami.FormData.label: "Maximum:"
        visible: random.checked
        from: 1
        to: 3600
        editable: true
        textFromValue: function(value) { return value + " seconds" }
        valueFromText: function(text) {
            const parsed = parseInt(text)
            return isNaN(parsed) ? 60 : parsed
        }
        onValueModified: if (value < lower.value) lower.value = value
    }

    Controls.CheckBox {
        id: startAtLaunch
        Kirigami.FormData.label: "Startup:"
        text: "Start actions when Move Mouse loads"
    }

    Controls.Label {
        Kirigami.FormData.isSection: true
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: "Because the widget is stored in your Plasma panel or desktop layout, it is automatically restored when Plasma starts."
    }
}

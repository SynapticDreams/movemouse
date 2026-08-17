import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_blackoutEnabled: enabled.checked
    property alias cfg_blackoutStart: start.text
    property alias cfg_blackoutEnd: end.text
    property alias cfg_blackoutMonday: mon.checked
    property alias cfg_blackoutTuesday: tue.checked
    property alias cfg_blackoutWednesday: wed.checked
    property alias cfg_blackoutThursday: thu.checked
    property alias cfg_blackoutFriday: fri.checked
    property alias cfg_blackoutSaturday: sat.checked
    property alias cfg_blackoutSunday: sun.checked

    Controls.CheckBox {
        id: enabled
        Kirigami.FormData.label: "Blackout:"
        text: "Pause actions during this time window"
    }

    Controls.TextField {
        id: start
        Kirigami.FormData.label: "Start:"
        enabled: enabled.checked
        placeholderText: "12:00"
        inputMask: "99:99"
    }

    Controls.TextField {
        id: end
        Kirigami.FormData.label: "End:"
        enabled: enabled.checked
        placeholderText: "13:00"
        inputMask: "99:99"
    }

    Controls.Label {
        Kirigami.FormData.isSection: true
        text: "Days"
        font.bold: true
    }

    RowLayout {
        Kirigami.FormData.label: "Black out on:"
        enabled: enabled.checked
        Controls.CheckBox { id: mon; text: "Mon" }
        Controls.CheckBox { id: tue; text: "Tue" }
        Controls.CheckBox { id: wed; text: "Wed" }
        Controls.CheckBox { id: thu; text: "Thu" }
    }

    RowLayout {
        enabled: enabled.checked
        Controls.CheckBox { id: fri; text: "Fri" }
        Controls.CheckBox { id: sat; text: "Sat" }
        Controls.CheckBox { id: sun; text: "Sun" }
    }

    Controls.Label {
        Kirigami.FormData.isSection: true
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: "While a blackout is active, the circular ring changes to purple and no simulated input is generated."
    }
}

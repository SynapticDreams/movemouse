import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_scheduleEnabled: enabled.checked
    property alias cfg_scheduleStart: start.text
    property alias cfg_scheduleEnd: end.text
    property alias cfg_scheduleMonday: mon.checked
    property alias cfg_scheduleTuesday: tue.checked
    property alias cfg_scheduleWednesday: wed.checked
    property alias cfg_scheduleThursday: thu.checked
    property alias cfg_scheduleFriday: fri.checked
    property alias cfg_scheduleSaturday: sat.checked
    property alias cfg_scheduleSunday: sun.checked

    Controls.CheckBox {
        id: enabled
        Kirigami.FormData.label: "Schedule:"
        text: "Only run Move Mouse during this time window"
    }

    Controls.TextField {
        id: start
        Kirigami.FormData.label: "Start:"
        enabled: enabled.checked
        placeholderText: "09:00"
        inputMask: "99:99"
    }

    Controls.TextField {
        id: end
        Kirigami.FormData.label: "End:"
        enabled: enabled.checked
        placeholderText: "17:00"
        inputMask: "99:99"
    }

    Controls.Label {
        Kirigami.FormData.isSection: true
        text: "Days"
        font.bold: true
    }

    RowLayout {
        Kirigami.FormData.label: "Active on:"
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
        text: "24-hour HH:MM format is used. Overnight windows such as 22:00–06:00 are supported."
    }
}

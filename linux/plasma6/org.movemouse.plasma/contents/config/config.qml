import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "Actions"
        icon: "input-mouse"
        source: "ConfigActions.qml"
    }
    ConfigCategory {
        name: "Behaviour"
        icon: "configure"
        source: "ConfigBehaviour.qml"
    }
    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-theme"
        source: "ConfigAppearance.qml"
    }
    ConfigCategory {
        name: "Schedules"
        icon: "view-calendar"
        source: "ConfigSchedules.qml"
    }
    ConfigCategory {
        name: "Blackouts"
        icon: "weather-clear-night"
        source: "ConfigBlackouts.qml"
    }
}

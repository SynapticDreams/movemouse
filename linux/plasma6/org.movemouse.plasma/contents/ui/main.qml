import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    property bool running: false
    property bool moveRight: true
    property string lastError: ""

    Plasmoid.icon: "input-mouse"
    Plasmoid.status: running ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    toolTipMainText: "Move Mouse"
    toolTipSubText: running ? "Active — moving every %1 seconds".arg(Plasmoid.configuration.intervalSeconds) : "Inactive"

    compactRepresentation: MouseArea {
        anchors.fill: parent
        onClicked: root.running = !root.running

        Kirigami.Icon {
            anchors.fill: parent
            source: root.running ? "input-mouse" : "input-mouse-click-left"
            opacity: root.running ? 1.0 : 0.65
        }
    }

    fullRepresentation: ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading {
            text: "Move Mouse"
            level: 2
        }

        Controls.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: root.running
                ? "Move Mouse is active. The pointer will move slightly every %1 seconds.".arg(Plasmoid.configuration.intervalSeconds)
                : "Move Mouse is stopped."
        }

        Controls.Button {
            Layout.fillWidth: true
            text: root.running ? "Stop" : "Start"
            icon.name: root.running ? "media-playback-stop" : "media-playback-start"
            onClicked: root.running = !root.running
        }

        Controls.Label {
            visible: root.lastError.length > 0
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: Kirigami.Theme.negativeTextColor
            text: root.lastError
        }

        Item { Layout.fillHeight: true }
    }

    Timer {
        id: moveTimer
        interval: Math.max(5, Plasmoid.configuration.intervalSeconds) * 1000
        running: root.running
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            const amount = Math.max(1, Plasmoid.configuration.movePixels)
            const dx = root.moveRight ? amount : -amount
            root.moveRight = !root.moveRight
            executable.connectSource("ydotool mousemove -x " + dx + " -y 0")
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            const exitCode = data["exit code"]
            if (exitCode !== undefined && exitCode !== 0) {
                root.lastError = "Mouse movement failed. Make sure ydotool is installed and the ydotool user service is running."
            } else {
                root.lastError = ""
            }
            disconnectSource(sourceName)
        }
    }
}

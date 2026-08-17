import QtQuick

Item {
    id: face

    property string stateName: "Idle"
    property real progress: 1.0
    property bool showStatus: true
    property bool showCountdown: true
    property bool animateMouse: true
    property int ringThickness: 10
    property bool compact: false
    property string errorText: ""

    signal activated()

    readonly property color stateColor: {
        switch (stateName) {
        case "Running": return "#39d000"
        case "Executing": return "#ff4e2b"
        case "Scheduled": return "#ffc400"
        case "Blackout": return "#7447c9"
        default: return "#62666d"
        }
    }

    implicitWidth: compact ? 40 : 210
    implicitHeight: compact ? 40 : 210

    onProgressChanged: ring.requestPaint()
    onStateColorChanged: ring.requestPaint()
    onShowCountdownChanged: ring.requestPaint()
    onRingThicknessChanged: ring.requestPaint()

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: Math.max(2, face.ringThickness / 2)
        radius: width / 2
        color: "#1b1d21"
        border.width: 1
        border.color: "#34383f"
    }

    Canvas {
        id: ring
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const thickness = Math.max(2, Math.min(face.ringThickness, width * 0.16))
            const radius = Math.max(1, Math.min(width, height) / 2 - thickness / 2 - 1)
            const cx = width / 2
            const cy = height / 2

            ctx.lineWidth = thickness
            ctx.lineCap = "round"
            ctx.strokeStyle = "#454950"
            ctx.beginPath()
            ctx.arc(cx, cy, radius, 0, Math.PI * 2)
            ctx.stroke()

            const amount = face.showCountdown ? Math.max(0, Math.min(1, face.progress)) : 1
            if (amount > 0.001 && face.stateName !== "Idle") {
                ctx.strokeStyle = face.stateColor
                ctx.beginPath()
                ctx.arc(cx, cy, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * amount, false)
                ctx.stroke()
            }
        }
    }

    Image {
        id: mascot
        anchors.centerIn: parent
        width: parent.width * (face.compact ? 0.67 : 0.62)
        height: width
        source: "../images/mouse.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true

        scale: face.stateName === "Executing" && face.animateMouse ? 1.08 : 1.0
        Behavior on scale {
            NumberAnimation { duration: face.animateMouse ? 120 : 0; easing.type: Easing.OutBack }
        }
    }

    Canvas {
        id: playBadge
        visible: face.stateName === "Idle"
        width: face.compact ? parent.width * 0.35 : parent.width * 0.25
        height: width
        anchors.right: mascot.right
        anchors.bottom: mascot.bottom
        anchors.rightMargin: -width * 0.18
        anchors.bottomMargin: -height * 0.05

        onVisibleChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = "#28d31a"
            ctx.strokeStyle = "#12660c"
            ctx.lineWidth = Math.max(1.5, width * 0.06)
            ctx.beginPath()
            ctx.moveTo(width * 0.22, height * 0.12)
            ctx.lineTo(width * 0.86, height * 0.5)
            ctx.lineTo(width * 0.22, height * 0.88)
            ctx.closePath()
            ctx.fill()
            ctx.stroke()
        }
    }

    Rectangle {
        visible: face.errorText.length > 0
        width: face.compact ? 11 : 22
        height: width
        radius: width / 2
        color: "#d93025"
        border.color: "#ffffff"
        border.width: 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: face.compact ? 1 : 10

        Text {
            anchors.centerIn: parent
            text: "!"
            color: "white"
            font.bold: true
            font.pixelSize: parent.height * 0.72
        }
    }

    Text {
        visible: face.showStatus && !face.compact
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.max(18, parent.height * 0.09)
        text: face.stateName
        color: "#f2f2f2"
        font.bold: true
        font.pixelSize: Math.max(11, parent.height * 0.065)
        style: Text.Outline
        styleColor: "#77000000"
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: face.activated()
    }

    SequentialAnimation {
        running: face.animateMouse && face.stateName === "Executing"
        loops: 1
        NumberAnimation { target: mascot; property: "rotation"; from: -4; to: 4; duration: 90 }
        NumberAnimation { target: mascot; property: "rotation"; from: 4; to: 0; duration: 90 }
    }
}

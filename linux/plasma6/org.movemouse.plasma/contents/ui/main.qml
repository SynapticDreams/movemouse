import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    property bool running: false
    property string stateName: "Idle"
    property real progress: 1.0
    property int cycleDurationMs: 30000
    property int elapsedMs: 0
    property bool suspended: false
    property bool movePositive: true
    property int squarePhase: 0
    property string lastError: ""

    // KDE Wayland does not expose pollable idle milliseconds. Instead we use
    // KIdleTime's native idle/resume events through the bundled helper.
    property bool inactivityCountdownActive: false
    property bool idleWaitPending: false
    property bool activityWaitPending: false
    property bool actionInFlight: false
    property int trackingEpoch: 0
    property string idleWaitSource: ""
    property string activityWaitSource: ""
    readonly property int activityArmDelayMs: 250

    Plasmoid.icon: "input-mouse"
    Plasmoid.status: running ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    toolTipMainText: "Move Mouse"
    toolTipSubText: lastError.length > 0
        ? lastError
        : stateName + (running && stateName === "Running" ? " — click to stop" : " — click to start/stop")

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: root.running ? "Stop Move Mouse" : "Start Move Mouse"
            icon.name: root.running ? "media-playback-stop" : "media-playback-start"
            onTriggered: root.toggleRunning()
        },
        PlasmaCore.Action {
            text: "Test actions now"
            icon.name: "tools-check-spelling"
            onTriggered: root.performActions(true)
        }
    ]

    compactRepresentation: MouseFace {
        anchors.fill: parent
        compact: true
        stateName: root.stateName
        progress: root.progress
        showStatus: false
        showCountdown: Plasmoid.configuration.showCountdown
        animateMouse: Plasmoid.configuration.animateMouse
        ringThickness: Math.max(3, Plasmoid.configuration.ringThickness / 2)
        errorText: root.lastError
        onActivated: root.toggleRunning()
    }

    fullRepresentation: MouseFace {
        implicitWidth: 210
        implicitHeight: 210
        stateName: root.stateName
        progress: root.progress
        showStatus: Plasmoid.configuration.showStatus
        showCountdown: Plasmoid.configuration.showCountdown
        animateMouse: Plasmoid.configuration.animateMouse
        ringThickness: Plasmoid.configuration.ringThickness
        errorText: root.lastError
        onActivated: root.toggleRunning()
    }

    function helperCommand(arguments, token) {
        return "bash -lc '\"$HOME/.local/libexec/movemouse/movemouse-idle-monitor\" "
            + arguments + " --token " + token + "'"
    }

    function toggleRunning() {
        running = !running
        lastError = ""

        if (running) {
            suspended = false
            resetCycle()
            refreshState()
            if (scheduleAllowsNow() && !blackoutActiveNow())
                startActivityTracking()
        } else {
            stopActivityTracking()
            elapsedMs = 0
            progress = 1.0
            stateName = "Idle"
        }
    }

    function chooseIntervalMs() {
        const lower = Math.max(1, Plasmoid.configuration.lowerInterval)
        const upper = Math.max(lower, Plasmoid.configuration.upperInterval)

        if (!Plasmoid.configuration.randomInterval)
            return lower * 1000

        return (lower + Math.floor(Math.random() * (upper - lower + 1))) * 1000
    }

    function resetCycle() {
        elapsedMs = 0
        cycleDurationMs = chooseIntervalMs()
        progress = 1.0
    }

    function stopActivityTracking() {
        trackingEpoch += 1
        inactivityCountdownActive = false

        if (idleWaitSource.length > 0)
            idleWaiter.disconnectSource(idleWaitSource)
        if (activityWaitSource.length > 0)
            activityWaiter.disconnectSource(activityWaitSource)

        idleWaitSource = ""
        activityWaitSource = ""
        idleWaitPending = false
        activityWaitPending = false
    }

    function startActivityTracking() {
        stopActivityTracking()
        resetCycle()
        armIdleWait()
    }

    function armIdleWait() {
        if (!running || idleWaitPending || blackoutActiveNow() || !scheduleAllowsNow())
            return

        const token = trackingEpoch
        idleWaitSource = helperCommand("--wait-idle " + activityArmDelayMs, token)
        idleWaitPending = true
        idleWaiter.connectSource(idleWaitSource)
    }

    function armActivityWait() {
        if (!running || activityWaitPending || blackoutActiveNow() || !scheduleAllowsNow())
            return

        const token = trackingEpoch
        activityWaitSource = helperCommand("--wait-activity", token)
        activityWaitPending = true
        activityWaiter.connectSource(activityWaitSource)
    }

    function parseMinutes(value) {
        if (!value)
            return -1

        const parts = value.split(":")
        if (parts.length !== 2)
            return -1

        const hour = parseInt(parts[0])
        const minute = parseInt(parts[1])
        if (isNaN(hour) || isNaN(minute) || hour < 0 || hour > 23 || minute < 0 || minute > 59)
            return -1

        return hour * 60 + minute
    }

    function currentMinutes() {
        const now = new Date()
        return now.getHours() * 60 + now.getMinutes()
    }

    function insideWindow(startText, endText) {
        const start = parseMinutes(startText)
        const end = parseMinutes(endText)
        const current = currentMinutes()

        if (start < 0 || end < 0)
            return true
        if (start === end)
            return true
        if (start < end)
            return current >= start && current < end
        return current >= start || current < end
    }

    function scheduleDayEnabled(day) {
        switch (day) {
        case 0: return Plasmoid.configuration.scheduleSunday
        case 1: return Plasmoid.configuration.scheduleMonday
        case 2: return Plasmoid.configuration.scheduleTuesday
        case 3: return Plasmoid.configuration.scheduleWednesday
        case 4: return Plasmoid.configuration.scheduleThursday
        case 5: return Plasmoid.configuration.scheduleFriday
        case 6: return Plasmoid.configuration.scheduleSaturday
        default: return false
        }
    }

    function blackoutDayEnabled(day) {
        switch (day) {
        case 0: return Plasmoid.configuration.blackoutSunday
        case 1: return Plasmoid.configuration.blackoutMonday
        case 2: return Plasmoid.configuration.blackoutTuesday
        case 3: return Plasmoid.configuration.blackoutWednesday
        case 4: return Plasmoid.configuration.blackoutThursday
        case 5: return Plasmoid.configuration.blackoutFriday
        case 6: return Plasmoid.configuration.blackoutSaturday
        default: return false
        }
    }

    function scheduleAllowsNow() {
        if (!Plasmoid.configuration.scheduleEnabled)
            return true

        const now = new Date()
        return scheduleDayEnabled(now.getDay())
            && insideWindow(Plasmoid.configuration.scheduleStart, Plasmoid.configuration.scheduleEnd)
    }

    function blackoutActiveNow() {
        if (!Plasmoid.configuration.blackoutEnabled)
            return false

        const now = new Date()
        return blackoutDayEnabled(now.getDay())
            && insideWindow(Plasmoid.configuration.blackoutStart, Plasmoid.configuration.blackoutEnd)
    }

    function refreshState() {
        if (!running) {
            stateName = "Idle"
            return
        }

        if (blackoutActiveNow()) {
            stateName = "Blackout"
            return
        }

        if (!scheduleAllowsNow()) {
            stateName = "Scheduled"
            return
        }

        stateName = "Running"
    }

    function movementCommand() {
        if (!Plasmoid.configuration.moveEnabled)
            return ""

        const amount = Math.max(1, Plasmoid.configuration.movePixels)
        let dx = 0
        let dy = 0

        switch (Plasmoid.configuration.moveDirection) {
        case 1:
            dy = movePositive ? amount : -amount
            movePositive = !movePositive
            break
        case 2:
            dx = movePositive ? amount : -amount
            dy = dx
            movePositive = !movePositive
            break
        case 3:
            if (squarePhase === 0) dx = amount
            else if (squarePhase === 1) dy = amount
            else if (squarePhase === 2) dx = -amount
            else dy = -amount
            squarePhase = (squarePhase + 1) % 4
            break
        case 4:
            dx = Math.round((Math.random() * 2 - 1) * amount)
            dy = Math.round((Math.random() * 2 - 1) * amount)
            if (dx === 0 && dy === 0)
                dx = amount
            break
        default:
            dx = movePositive ? amount : -amount
            movePositive = !movePositive
            break
        }

        return "ydotool mousemove -x " + dx + " -y " + dy
    }

    function clickCommand() {
        if (!Plasmoid.configuration.clickEnabled)
            return ""

        const buttons = ["0xC0", "0xC1", "0xC2"]
        const index = Math.max(0, Math.min(2, Plasmoid.configuration.clickButton))
        return "ydotool click " + buttons[index]
    }

    function performActions(manualTest) {
        if (actionInFlight)
            return

        const commands = []
        const move = movementCommand()
        const click = clickCommand()

        if (move.length > 0)
            commands.push(move)
        if (click.length > 0)
            commands.push(click)

        if (commands.length === 0) {
            lastError = "No actions are enabled. Right-click the widget and open Configure Move Mouse."
            return
        }

        actionInFlight = true
        stateName = "Executing"
        executable.connectSource("bash -lc '" + commands.join(" && ") + "'")
        executionFlash.restart()
    }

    Timer {
        id: ticker
        interval: 100
        repeat: true
        running: root.running

        onTriggered: {
            const blockedByBlackout = root.blackoutActiveNow()
            const blockedBySchedule = !root.scheduleAllowsNow()

            if (blockedByBlackout || blockedBySchedule) {
                if (!root.suspended) {
                    root.suspended = true
                    root.stopActivityTracking()
                }
                root.progress = 1.0
                root.stateName = blockedByBlackout ? "Blackout" : "Scheduled"
                return
            }

            if (root.suspended) {
                root.suspended = false
                root.startActivityTracking()
            }

            if (root.stateName !== "Executing")
                root.stateName = "Running"

            if (!root.inactivityCountdownActive) {
                root.progress = 1.0
                return
            }

            root.elapsedMs += interval
            root.progress = Math.max(0, 1.0 - root.elapsedMs / root.cycleDurationMs)

            if (root.elapsedMs >= root.cycleDurationMs && !root.actionInFlight)
                root.performActions(false)
        }
    }

    Timer {
        id: executionFlash
        interval: 300
        repeat: false
        onTriggered: root.refreshState()
    }

    Plasma5Support.DataSource {
        id: idleWaiter
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            const isCurrent = sourceName === root.idleWaitSource
            disconnectSource(sourceName)
            if (!isCurrent)
                return

            root.idleWaitPending = false
            root.idleWaitSource = ""

            const exitCode = data["exit code"]
            if (exitCode !== undefined && exitCode !== 0) {
                root.lastError = "KDE idle detection failed. Re-run the CachyOS installer to build the idle monitor."
                return
            }

            if (!root.running || root.blackoutActiveNow() || !root.scheduleAllowsNow())
                return

            root.inactivityCountdownActive = true
            root.elapsedMs = Math.min(root.activityArmDelayMs, root.cycleDurationMs)
            root.progress = Math.max(0, 1.0 - root.elapsedMs / root.cycleDurationMs)
            root.armActivityWait()
        }
    }

    Plasma5Support.DataSource {
        id: activityWaiter
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            const isCurrent = sourceName === root.activityWaitSource
            disconnectSource(sourceName)
            if (!isCurrent)
                return

            root.activityWaitPending = false
            root.activityWaitSource = ""

            const exitCode = data["exit code"]
            if (exitCode !== undefined && exitCode !== 0) {
                root.lastError = "KDE activity detection failed. Re-run the CachyOS installer to build the idle monitor."
                return
            }

            if (!root.running)
                return

            // A real keyboard/mouse event occurred. Reset the full interval and
            // wait until the session becomes idle again before counting down.
            root.inactivityCountdownActive = false
            root.startActivityTracking()
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            const exitCode = data["exit code"]
            root.actionInFlight = false

            if (exitCode !== undefined && exitCode !== 0) {
                root.lastError = "Move Mouse could not generate input. Check that ydotool is installed and ydotool.service is running."
                root.running = false
                root.stopActivityTracking()
                root.stateName = "Idle"
            } else {
                root.lastError = ""
                if (root.running)
                    root.startActivityTracking()
            }
            disconnectSource(sourceName)
        }
    }

    Component.onCompleted: {
        resetCycle()
        if (Plasmoid.configuration.startAtLaunch)
            toggleRunning()
    }
}

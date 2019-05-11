import QtQuick 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    Item {
        property string outputText: ""
        property string activePanelIcon: ""
        id: stdoutItem
        PlasmaCore.DataSource {
            id: getWithStdout
            engine: "executable"
            connectedSources: []
            onNewData: {
                var exitCode = data["exit code"]
                var exitStatus = data["exit status"]
                var stdout = data["stdout"]
                var stderr = data["stderr"]
                exited(sourceName, exitCode, exitStatus, stdout, stderr)
                disconnectSource(sourceName) // cmd finished
            }
            function exec(cmd) {
                if (cmd) {
                    connectSource(cmd)
                }
            }
            signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
        }
        
        Connections {
            target: getWithStdout
            onExited: {
                stdoutItem.outputText = stdout.replace('\n', ' ').trim()
                if (stdoutItem.outputText.toLowerCase().includes("nvidia")) {
                    stdoutItem.activePanelIcon = "nvidia"
                } else {
                    stdoutItem.activePanelIcon = "intel"
                }
            }
        }

        Timer {
            id: timer
            interval: 500
            running: true
            repeat: true
            onTriggered: {
                getWithStdout.exec("/usr/sbin/prime-select get-current")
            }
            Component.onCompleted: {
                triggered()
            }
        }
    }
    Plasmoid.compactRepresentation: PlasmaCore.IconItem {
        source: stdoutItem.activePanelIcon
        width: units.iconSizes.medium
        height: units.iconSizes.medium
        active: mouseArea.containsMouse

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: plasmoid.expanded = !plasmoid.expanded
            hoverEnabled: true
        }
    }

    Plasmoid.fullRepresentation: Dropdown {}

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
}   
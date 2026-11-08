import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool vertical: true

    // LEFT / RIGHT BAR
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6

        spacing: 12
        visible: root.vertical

        // Everything in this group stays at the TOP.
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true

            spacing: 12

            LogoButton {
                Layout.alignment: Qt.AlignHCenter
            }

            // Workspaces immediately below shortcuts
            WorkspaceIndicator {
                vertical: true
                Layout.alignment: Qt.AlignHCenter
            }
        }

        

        // Flexible empty space
        Item {
            Layout.fillHeight: true
        }

        // System indicators stay at the BOTTOM.
        SystemIndicators {
            vertical: true
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // Workspace description: vertically centered
    WorkspaceDescription {
        visible: root.vertical

        width: 60
        height: 20

        anchors.horizontalCenter: root.horizontalCenter
        anchors.verticalCenter: root.verticalCenter

        rotation: -90
    }

    // TOP / BOTTOM BAR
    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        spacing: 16
        visible: !root.vertical

        LogoButton {}

        WorkspaceIndicator {
            vertical: false
        }

        WorkspaceDescription {
            width: 60
            height: 40
        }

        Item {
            Layout.fillWidth: true
        }

        SystemIndicators {
            vertical: false
        }
    }
}
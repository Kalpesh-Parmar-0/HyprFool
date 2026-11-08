import QtQuick

Item {
    id: root

    property bool vertical: true
    property int activeWorkspace: 1

    implicitWidth: vertical ? 40 : 176
    implicitHeight: vertical ? 176 : 40

    readonly property color activeColor: "#38bdf8"
    readonly property color inactiveColor: "#30384d"
    readonly property color textColor: "#cdd6f4"

    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.vertical

        Repeater {
            model: 4

            delegate: WorkspaceItem {
                required property int index

                workspaceNumber: index + 1
                active: root.activeWorkspace === index + 1
                activeColor: root.activeColor
                inactiveColor: root.inactiveColor
                textColor: root.textColor
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8
        visible: !root.vertical

        Repeater {
            model: 4

            delegate: WorkspaceItem {
                required property int index

                workspaceNumber: index + 1
                active: root.activeWorkspace === index + 1
                activeColor: root.activeColor
                inactiveColor: root.inactiveColor
                textColor: root.textColor
            }
        }
    }

    component WorkspaceItem: Rectangle {
        id: workspace

        required property int workspaceNumber
        required property bool active
        required property color activeColor
        required property color inactiveColor
        required property color textColor

        property bool hovered: false

        width: active ? 36 : 32
        height: active ? 36 : 32

        radius: active ? 11 : 9

        color: active
            ? activeColor
            : (hovered ? "#454d64" : inactiveColor)

        scale: hovered ? 1.06 : 1.0

        Behavior on width {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 180
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutBack
            }
        }

        Text {
            anchors.centerIn: parent

            text: workspace.workspaceNumber

            color: workspace.active
                ? "#172033"
                : workspace.textColor

            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        HoverHandler {
            onHoveredChanged: workspace.hovered = hovered
        }
    }
}
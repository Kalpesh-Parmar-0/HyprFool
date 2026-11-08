import QtQuick

Item {
    id: root

    implicitWidth: 40
    implicitHeight: 40

    property bool hovered: false

    Rectangle {
        anchors.centerIn: parent

        width: 38
        height: 38
        radius: 12

        color: root.hovered
            ? "#30384d"
            : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 180
            }
        }
    }

    Image {
        anchors.centerIn: parent

        width: 30
        height: 30

        source: "file:///usr/share/icons/hicolor/96x96/apps/fedora-logo-icon.png"

        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true

        scale: root.hovered ? 1.12 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutBack
            }
        }
    }

    HoverHandler {
        onHoveredChanged: root.hovered = hovered
    }
}
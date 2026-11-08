import QtQuick
import Quickshell
import "../../config" as Config

PanelWindow {
    id: root

    readonly property string position: Config.BarConfig.position

    readonly property bool vertical:
        position === "left" || position === "right"

    color: "transparent"

    exclusiveZone: Config.BarConfig.thickness

    width: vertical ? Config.BarConfig.thickness : 1
    height: vertical ? 1 : Config.BarConfig.thickness

    anchors {
        left: position === "left" || !vertical
        right: position === "right" || !vertical
        top: position === "top" || vertical
        bottom: position === "bottom" || vertical
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"

        radius: Config.BarConfig.floating
            ? Config.BarConfig.radius
            : 0

        Item {
            id: animatedContent

            anchors.fill: parent
            opacity: 0

            transform: Translate {
                id: entranceShift

                x: root.vertical
                    ? (root.position === "right" ? 10 : -10)
                    : 0

                y: root.vertical
                    ? 0
                    : (root.position === "bottom" ? 10 : -10)
            }

            BarContent {
                anchors.fill: parent
                vertical: root.vertical
            }

            ParallelAnimation {
                id: entrance

                NumberAnimation {
                    target: animatedContent
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 280
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    target: entranceShift
                    property: "x"
                    to: 0
                    duration: 350
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    target: entranceShift
                    property: "y"
                    to: 0
                    duration: 350
                    easing.type: Easing.OutCubic
                }
            }

            Component.onCompleted: entrance.start()
        }
    }
}
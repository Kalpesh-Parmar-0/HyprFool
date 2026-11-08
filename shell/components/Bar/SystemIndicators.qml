import QtQuick

Item {
    id: root

    property bool vertical: true

    implicitWidth: vertical ? 40 : 144
    implicitHeight: vertical ? 144 : 40

    readonly property var symbols: ["⌁", "ᛒ", "◖", "ϟ"]

    Column {
        anchors.centerIn: parent
        spacing: 13
        visible: root.vertical

        Repeater {
            model: root.symbols

            delegate: IndicatorIcon {
                required property string modelData
                symbol: modelData
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 13
        visible: !root.vertical

        Repeater {
            model: root.symbols

            delegate: IndicatorIcon {
                required property string modelData
                symbol: modelData
            }
        }
    }

    component IndicatorIcon: Item {
        id: iconRoot

        required property string symbol

        width: 24
        height: 24

        property bool hovered: false

        Text {
            anchors.centerIn: parent

            text: iconRoot.symbol
            color: iconRoot.hovered ? "#89b4fa" : "#cdd6f4"

            font.pixelSize: 17

            scale: iconRoot.hovered ? 1.2 : 1.0

            Behavior on color {
                ColorAnimation { duration: 160 }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }
        }

        HoverHandler {
            onHoveredChanged: iconRoot.hovered = hovered
        }
    }
}
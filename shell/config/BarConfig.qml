pragma Singleton

import QtQuick

QtObject {
    // Available: left, right, top, bottom
    property string position: "left"

    // Bar dimensions
    property int thickness: 56
    property int margin: 0

    // Appearance
    property string appearance: "attached"
    property int radius: 16

    // Behavior
    property string autoHide: "never"

    Derived properties
    readonly property bool vertical:
        position === "left" || position === "right"

    readonly property bool horizontal:
        position === "top" || position === "bottom"

    readonly property bool floating:
        appearance === "floating"
}
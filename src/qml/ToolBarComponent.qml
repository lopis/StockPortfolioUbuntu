import QtQuick 2.0
import Ubuntu.Components 0.1

Component {
    ToolbarItems {
        id: mainToolbar
        locked: false
        opened: false
        ToolbarButton {
            iconSource: Qt.resolvedUrl("graphics/button_add.svg")
            text: "Add New"
        }

        ToolbarButton {
            id: buttonEdit
            iconSource: Qt.resolvedUrl("graphics/button_edit.svg")
            text: "Manage"
            onTriggered: {
                buttonEdit.iconSource = Qt.resolvedUrl("graphics/button_add.svg");
            }
        }
    }
}

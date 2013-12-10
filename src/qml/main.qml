import QtQuick 2.0
import Ubuntu.Components 0.1
import FileIO 1.0
import "data.js" as DataJS

MainView {
    id: root
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer.joao.StockPortfolio"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    //width: units.gu(66)
    //height: units.gu(106)

    PageStack {
        id: pageStack
        anchors.fill: parent
        property int tickID: -1
        Component.onCompleted: push(mainPage)

        // Placed the List Model in the root to be globally accessible
        ListModel {
            id: tickListModel
        }

        Page {
            id: mainPage
            title: "Stocks Portfolio"
            anchors.fill: parent
            anchors.topMargin: parent.header.height
            visible: false;
            property url up_arrow: Qt.resolvedUrl("graphics/up_arrow.png")
            property url down_arrow: Qt.resolvedUrl("graphics/down_arrow.png")

            tools: ToolbarItems {
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

            ListedView {
                objectName: "listedView"
            }
        }
    }

    Component.onCompleted: {
        if (parent) {
            root.anchors.fill = parent;
        } else {
            root.width = units.gu(66);
            root.height = units.gu(106);
        }
    }

}

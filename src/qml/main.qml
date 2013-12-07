import QtQuick 2.0
import Ubuntu.Components 0.1
import "data.js" as DataFile

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


    Loader {
        anchors.fill: parent
        id: mainLoader
        property string tickName
    }

    // Placed the List Model in the root to be globally accessible
    ListModel {
        id: tickListModel
    }

    Component.onCompleted: {
        if (parent) {
            root.anchors.fill = parent;
        } else {
            root.width = units.gu(66);
            root.height = units.gu(106);
        }

        console.log(root.height);
        mainLoader.source = "ListedView.qml";
    }

}

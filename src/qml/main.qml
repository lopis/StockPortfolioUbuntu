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


    Loader {
        anchors.fill: parent
        id: mainLoader
        property string tickName
    }

    // Placed the List Model in the root to be globally accessible
    ListModel {
        id: tickListModel
    }

    FileIO {
        id: dataFile
        source: "/home/phablet/.cache/com.ubuntu.joao.StockPortfolioCpp/data"
        onError: console.log(msg)
        function parse() {
            var readString = read();
            console.log(readString);
            if (readString === "") {
                // File empty or not read. Use default values.
                readString = DataJS.defaultNames;
            }

            var readValues = readString.split(";");
            for (var value in readValues) {
                // console.log("Value: '" + readValues[value] + "'");
                var splitValue = readValues[value].split(",");
                var newTick = {};
                newTick["name"] = splitValue[1];
                newTick["tickName"] = splitValue[0];
                newTick["valuesObj"] = [];
                newTick["raisedPercent"] = "";
                newTick["normValues"] = [];
                tickListModel.append(newTick);
                console.log(JSON.stringify(newTick));
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
        dataFile.parse(); // Parse portfolio meta data from local file
        console.log(root.height);
        mainLoader.source = "ListedView.qml";
    }

}

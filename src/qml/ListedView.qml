import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import FileIO 1.0
import "data.js" as DataJS

Rectangle {
    id: listedViewContents
    anchors.fill: parent

    ListView {
        id: tickList
        anchors.fill: parent

        model: tickListModel
        delegate: ListItem.MultiValue {
            text: name
            icon: Qt.resolvedUrl(raisedPercent > 0 ? mainPage.up_arrow : mainPage.down_arrow)
            iconFrame: false
            values: [" <strong>" + tickName +
                "</strong> " + (raisedPercent > 0 ? "+" : "") +
                raisedPercent + "% ",
                numShares + " " +
                (numShares == 1 ? "share" : "shares") +
                " (" + valuesObj.get(0).close + ")"
            ]
            progression: true
            onClicked: {
                console.log("TickName selected: " + tickName)
                pageStack.tickID = tickID;
                pageStack.push(Qt.resolvedUrl("TabbedView.qml"));
            }
        }
    }

    ActivityIndicator {
        id: activityIndicator
        running: true
        visible: true
        anchors.centerIn: parent
    }

    FileIO {
        id: dataFile
        source: "/home/phablet/.cache/com.ubuntu.joao.stockportfolio/data"
        onError: statusText.text = msg
        function parse() {
            statusText.text = "Parsing file"
            var readString = read();
            if (readString === "" || !readString) {
                // File empty or not read. Use default values.
                statusText.text = "User data file not found. Using default."
                readString = DataJS.defaultNames;
            }

            var readValues = readString.split(";");
            for (var value in readValues) {
                // console.log("Value: '" + readValues[value] + "'");
                var splitValue = readValues[value].split(",");
                var newTick = {};
                newTick["tickName"] = splitValue[0];
                newTick["name"] = splitValue[1];
                newTick["valuesObj"] = [];
                newTick["raisedPercent"] = "";
                newTick["numShares"] = parseInt(splitValue[2]);
                newTick["volume"] = 0;
                newTick["normValues"] = [];
                newTick["tickID"] = parseInt(value);
                tickListModel.append(newTick);
            }
            statusText.text = "Portfolio ready."
        }
    }

    Component.onCompleted: {
        statusText.text = "ListedView completed"
        dataFile.parse(); // Parse portfolio meta data from local file
        tickList.visible = false;
        statusText.text = "Getting data"
        DataJS.status = statusText;
        DataJS.getData(tickList.model, function(){
            activityIndicator.running = false;
            tickList.visible = true;
            statusText.text = "ListedView Completed"
        }, 1);
    }
}

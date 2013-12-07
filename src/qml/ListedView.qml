import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import FileIO 1.0
import "data.js" as DataFile

Rectangle {
    anchors.fill: parent

    Page {
        id: mainPage
        title: "Stocks Portfolio"
        anchors.fill: parent
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

        ListView {
            id: tickList
            anchors.fill: parent
            model: tickListModel
            delegate: ListItem.SingleValue {
                text: " <strong>" + tickName + "</strong> " + (raisedPercent > 0 ? "+" : "") + raisedPercent + "%"
                iconSource: (raisedPercent > 0 ? mainPage.up_arrow : mainPage.down_arrow)
                iconFrame: false
                value: name
                progression: true
                onClicked: {
                    mainLoader.tickName = tickName;
                    mainLoader.source = "TabbedView.qml";

                }
            }
        }

//        Column {
//            id: pageLayout
//            width: parent.width
//            Button {
//                width: units.gu(12)
//                text: "Load Chart"
//                onClicked: pageLoader.source = "TabbedView.qml"
//            }
//        }

//        FileIO {
//            id: myFile
//            source: "/home/phablet/.cache/com.ubuntu.joao.StockPortfolioCpp/my_file.txt"
//            onError: console.log(msg)
//        }

        Component.onCompleted: {
//            console.log("WRITE: " + myFile.source)
//            console.log( "WRITE: "+ myFile.write("TEST"));
//            myText.text =  myFile.read();
            DataFile.getData(function(){
                var i = 0;
                for(var tickName in DataFile.portfolio) {
                    tickList.model.append(DataFile.portfolio[tickName]);
                }
                console.log("List count: " + tickList.height);
            });
        }
    }


}

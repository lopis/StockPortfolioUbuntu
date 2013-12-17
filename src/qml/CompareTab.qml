import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import "data.js" as DataJS

Tab {
    title: i18n.tr("Compare")
    width: parent.width

    id: plotPage
    property int plotHeight: 280
    property url up_arrow: Qt.resolvedUrl("/home/phablet/.cache/com.ubuntu.joao.stockportfolio/graphics/up_arrow.png")
    property url down_arrow: Qt.resolvedUrl("/home/phablet/.cache/com.ubuntu.joao.stockportfolio/graphics/down_arrow.png")

    Component.onCompleted: {
        tickListModel.get(tickID)["plotID"] = 0;
        compareList.addCompare(tickListModel.get(tickID));

    }

    function setLoading(loading) {
        plotActivityIndicator.visible = loading;
        if (!loading) {
            plotCanvas.normalizeValues(compareList.model);
        }
    }

    function addCompare(newTickName) {
        for (var i =0; i < compareList.model.count; i++) {
            if (compareList.model.get(i).tickName === newTickName){
                return "Already comparing " + newTickName;
            }
        }

        for (i = 0; i < tickListModel.count; i++) {
            if (tickListModel.get(i).tickName === newTickName) {
                tickListModel.get(i)["plotID"] = compareList.model.count;
                compareList.addCompare(tickListModel.get(i));
                plotCanvas.normalizeValues(compareList.model);
                statusText.text = "Added to compare: " + newTickName
                tabbedView.selectedTabIndex = 1;
                return "";
            }
        }

        return newTickName + " not found";
    }

    Rectangle {
        id: multiPlotColumn
        anchors.fill: parent
        visible: true

        ListItem.Empty {
            height: 280
            z: 1
            PlotCanvas {
                id: plotCanvas
            }
            ActivityIndicator {
                id: plotActivityIndicator
                running: true
                visible: false
                anchors.centerIn: plotCanvas
                onRunningChanged: {
                    plotCanvas.visible = !plotActivityIndicator.visible
                }
            }
        }
        ListView {
            id: compareList
            model: compareListModel
            anchors.fill: parent
            anchors.topMargin: 280
            z: 0
            property variant strokeColors : [
                "#149cdc","#dc4814","#14dc64","#dc1445","#5114dc"
            ]

            function addCompare(obj) {
                obj["lineIconIndex"] = compareListModel.count;
                compareListModel.append(obj);
            }

            delegate: ListItem.MultiValue {
                text: name
                icon: (raisedPercent > 0 ? plotPage.up_arrow : plotPage.down_arrow)
                iconFrame: false
                property int lineIcon: lineIconIndex
                values: [" <strong>" + tickName +
                    "</strong> " + (raisedPercent > 0 ? "+" : "") +
                    raisedPercent + "% ",
                    numShares + " " +
                    (numShares == 1 ? "share" : "shares") +
                    " (" + valuesObj.get(0).close + ")"
                ]
                progression: false
                onTriggered: {
                    // should remove itself
                    for (var i = 0; i < compareList.model.count; i++) {
                        console.log(tickName + "-" + compareList.model.get(i).tickName);
                        if (compareList.model.get(i).tickName === tickName && tickID != tabbedPage.tickID) {
                            compareList.model.remove(i);
                            return;
                        }
                    }
                }

                Image {
                    property variant strokeIcons :[
                        "line_blue.svg",
                        "line_aubergine.svg",
                        "line_orange.svg",
                        "line_pink.svg",
                        "line_green.svg",
                    ]
                    property string graphicsPath: "/home/phablet/.cache/com.ubuntu.joao.stockportfolio/graphics/"
                    height: parent.height
                    width: parent.height
                    source: Qt.resolvedUrl(graphicsPath + strokeIcons[lineIconIndex])
                    anchors.right: parent.right
                }
            }
        }
    }
}

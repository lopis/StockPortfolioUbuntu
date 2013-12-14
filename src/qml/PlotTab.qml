import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "data.js" as DataFile

Tab {
    title: i18n.tr("Portfolio")
    width: parent.width

    id: plotPage
    property int plotHeight: 280
    property url up_arrow: Qt.resolvedUrl("/home/phablet/.cache/com.ubuntu.joao.stockportfolio/graphics/up_arrow.png")
    property url down_arrow: Qt.resolvedUrl("/home/phablet/.cache/com.ubuntu.joao.stockportfolio/graphics/down_arrow.png")

    Component.onCompleted: {}

    function setLoading(loading) {
        plotActivityIndicator.visible = loading;
        if (!loading) {
            compareListModel.clear();
            compareListModel.append(tickListModel.get(tickID));
            plotCanvas.normalizeValues(compareListModel);
        }
    }

    Column {
        id: singlePlotColumn
        spacing: units.gu(1)
        width: parent.width

        MouseArea {
            id: plotMouseArea
            width: root.width
            height: plotPage.plotHeight
            onClicked: {
                plotCanvas.setTouch(plotMouseArea.mouseX, plotMouseArea.mouseY)
                var selectedIndex = plotCanvas.touchIndex;
                if (selectedIndex < 1) selectedIndex = 1;
                var curVal = tickListModel.get(tickID).valuesObj.get(selectedIndex).close;
                var oldVal = tickListModel.get(tickID).valuesObj.get(selectedIndex-1).close;
                itemPercent.percent = (100*(curVal-oldVal)/oldVal).toFixed(2);
                //itemPercent.percent = tickListModel.get(seletedIndex).valuesObj.get(seletedIndex);
                itemPercent.values = [tickListModel.get(tickID).valuesObj.get(selectedIndex).date];
            }

            PlotCanvas {
                id: plotCanvas
            }

            ActivityIndicator {
                id: plotActivityIndicator
                running: true
                visible: false
                anchors.centerIn: plotCanvas
            }
        }

        ListItem.MultiValue {
            text: tickListModel.get(tickID).name
            iconFrame: false
            values: [tickListModel.get(tickID).tickName]
            progression: false
        }

        ListItem.MultiValue {
            id: itemPercent
            property real percent: tickListModel.get(tickID).raisedPercent
            text: (percent > 0 ? "+" : "") + percent.toFixed(2) + "%"
            icon: (percent > 0 ? plotPage.up_arrow : plotPage.down_arrow)
            iconFrame: false
            values: [tickListModel.get(tickID).valuesObj.get(0).date]
            progression: false
        }

        ListItem.MultiValue {
            text: tickListModel.get(tickID).valuesObj.get(0).volume
            iconFrame: false
            values: ["Volume"]
            progression: false
        }

        ListItem.MultiValue {
            text: (tickListModel.get(tickID).numShares * tickListModel.get(tickID).valuesObj.get(0).close) +
                  " (" + tickListModel.get(tickID).numShares +
                  (tickListModel.get(tickID).numShares == 1 ? " share" : " shares") + ")"
            iconFrame: false
            values: ["Share Total"]
            progression: false
        }
    }
}

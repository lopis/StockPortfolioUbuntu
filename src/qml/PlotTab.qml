import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "data.js" as DataFile

Tab {
    title: i18n.tr("Portfolio")
    width: parent.width

    id: plotPage
    property int plotHeight: 280
    property url up_arrow: Qt.resolvedUrl("graphics/up_arrow.png")
    property url down_arrow: Qt.resolvedUrl("graphics/down_arrow.png")

    Component.onCompleted: {}

    Column {
        id: singlePlotColumn
        spacing: units.gu(1)
        width: parent.width

        PlotCanvas {
            id: plotCanvas
        }

        ListItem.SingleValue {
            text:  tickListModel.get(tickID).name + "  " + (tickListModel.get(tickID).raisedPercent > 0 ? "+" : "") + tickListModel.get(tickID).raisedPercent + "%"
            iconSource: (tickListModel.get(tickID).raisedPercent > 0 ? plotPage.up_arrow : plotPage.down_arrow)
            iconFrame: false
            value: "<strong>" + tickListModel.get(tickID).tickName + "</strong>"
            progression: false
        }


        ActivityIndicator {
            id: activityIndicator
            running: true
            visible: false
            anchors.horizontalCenter: singlePlotColumn.horizontalCenter
        }
    }
}

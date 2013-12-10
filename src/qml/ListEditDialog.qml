import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

ListView {
    id: dialogList
    anchors.fill: parent
    model: tickListModel
    delegate: ListItem.SingleValue {
        text: " <strong>" + tickName + "</strong> "
        iconFrame: false
        value: name
        progression: true
        onClicked: {
            console.log("Tick count: " + (tickListModel.count))
            console.log("TickID: " + tickID)
            for(var i = tickID+1; i < tickListModel.count; i++) {
                tickListModel.get(i).tickID -= 1;
                console.log("Decreasing tick " + i + " to " + tickListModel.get(i).tickID);
            }
            tickListModel.remove(tickID);
        }
    }
}



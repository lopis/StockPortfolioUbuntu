import QtQuick 2.0
import Ubuntu.Components 0.1

/*!
    \brief MainView with Tabs element.
           First Tab has a single Label and
           second Tab has a single ToolbarAction.
*/

Page {
    id: tabbedPage
    visible: false
    property string tickID: pageStack.tickID

    Component.onCompleted: {}

    tools: ToolbarItems {
        locked: false
        opened: false
    }

    Tabs {
        id: tabbedView

        PlotTab {
            id: plotTab
            width: parent.width
            objectName: "plotTab"
            property bool isReady : false;
        }

        CompareTab {
            objectName: "compareTab"
        }
    }
}

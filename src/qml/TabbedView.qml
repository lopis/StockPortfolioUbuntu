import QtQuick 2.0
import Ubuntu.Components 0.1

/*!
    \brief MainView with Tabs element.
           First Tab has a single Label and
           second Tab has a single ToolbarAction.
*/

Tabs {
    id: tabbedView
    width: parent.width

    PlotTab {
        width: parent.width
        objectName: "plotTab"
    }

    CompareTab {
        objectName: "compareTab"
    }
}

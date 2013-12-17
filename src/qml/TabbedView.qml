import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import "data.js" as DataJS

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

    ListModel {
        id: compareListModel
    }

    tools: ToolbarItems {
        id: tabsTools
        locked: false
        opened: false
        function setCalendar(nMonths) {
            compareTab.setLoading(true);
            plotTab.setLoading(true);
            DataJS.getData(tickListModel, function() {
                compareTab.setLoading(false);
                plotTab.setLoading(false);
            }, nMonths);
        }

        ToolbarButton {
            id: button12Months
            iconSource: Qt.resolvedUrl("graphics/calendar12.svg")
            text: "Year"
            onTriggered: tabsTools.setCalendar(12)
        }
        ToolbarButton {
            id: button6Months
            iconSource: Qt.resolvedUrl("graphics/calendar6.svg")
            text: "Semestre"
            onTriggered: tabsTools.setCalendar(6)
        }
        ToolbarButton {
            id: button1Month1
            iconSource: Qt.resolvedUrl("graphics/calendar1.svg")
            text: "Month"
            onTriggered: tabsTools.setCalendar(1)
        }
        ToolbarButton {
            id: buttonAddComp
            iconSource: Qt.resolvedUrl("graphics/button_add.svg")
            text: "Compare"
            onTriggered: {
                PopupUtils.open(popCompareAdd, buttonAddComp)
            }
        }
    }

    Tabs {
        id: tabbedView

        PlotTab {
            id: plotTab
            width: parent.width
            property bool isReady : false;
        }

        CompareTab {
            id: compareTab
        }
    }

    Component {
        id: popCompareAdd
        DefaultSheet {
            id: popoverCompareAdd
            onVisibleChanged: addCompareField.forceActiveFocus();

            Column {
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                }
                ListItem.Header {
                    text: "Add Tick Name"
                }
                ListItem.SingleControl {
                    pressed: false
                    control: TextField {
                        id: addCompareField
                        placeholderText: "Tick Name"
                    }
                }
                ListItem.SingleControl {
                    id: compareAddStatus
                    pressed: false
                    visible: false
                    control: Text {
                        text: "<no status>"
                    }
                    function setStatus(str) {
                        control.text = str;
                        visible = true;
                    }
                }

                ListItem.SingleControl {
                    pressed: false
                    id: compareButton
                    control: Button {
                        text: "Compare"
                        onClicked: {
                            statusText.text = "Searching for " + addCompareField.text
                            var newTickName = addCompareField.text.toUpperCase();
                            var err = compareTab.addCompare(newTickName);
                            if(err !== ""){
                                compareAddStatus.visible = true;
                                compareAddStatus.setStatus(err);
                            } else {
                                PopupUtils.close(popoverCompareAdd);
                            }
                        }
                    }
                }

            }
        }
    }
}

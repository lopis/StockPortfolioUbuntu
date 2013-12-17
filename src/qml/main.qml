import QtQuick 2.0
import Ubuntu.Components 0.1
import FileIO 1.0
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
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

    width: units.gu(50)
    height: units.gu(80)

    PageStack {
        id: pageStack
        anchors.fill: parent
        property int tickID: -1
        Component.onCompleted: {
            statusText.text = "PageStack completed"
            push(mainPage)
        }

        // Placed the List Model in the root to be globally accessible
        ListModel {
            id: tickListModel
        }

        Text {
            id: statusText
            text : "< No Status >"
            visible: true
        }

        Page {
            id: mainPage
            title: "Stocks Portfolio"
            anchors.fill: parent
            anchors.topMargin: parent.header.height
            visible: false;
            property url up_arrow: "graphics/up_arrow.png"
            property url down_arrow: "graphics/down_arrow.png"

            tools: ToolbarItems {
                locked: false
                opened: false
                ToolbarButton {
                    id: buttonAdd
                    iconSource: Qt.resolvedUrl("graphics/button_add.svg")
                    text: "Add New"
                    onTriggered: {
                        PopupUtils.open(popListAdd, buttonAdd)
                    }
                }

                ToolbarButton {
                    id: buttonEdit
                    iconSource: Qt.resolvedUrl("graphics/button_edit.svg")
                    text: "Manage"
                    onTriggered: {
                        PopupUtils.open(popoverComponent, buttonEdit)
                    }
                }
            }

            Component {
                id: popoverComponent
                Popover {
                    id: popover
                    Column {
                        id: containerLayout
                        anchors {
                            left: parent.left
                            top: parent.top
                            right: parent.right
                        }
                        ListItem.Header {
                            text: "Manage Portfolio"
                        }
                        ListItem.SingleControl {
                            pressed: false
                            control: Text {
                                text: "Remove One"
                            }
                            onClicked: {
                                PopupUtils.open(removeDialog)
                            }
                        }
                        ListItem.SingleControl {
                            pressed: false
                            control: Text {
                                text: "Remove All"
                            }
                            onClicked: {
                                tickListModel.clear()
                            }
                        }
                        ListItem.SingleControl {
                            pressed: false
                            control: Text {
                                text: "Close"
                            }
                            onClicked: {
                                PopupUtils.close(popover)
                            }
                        }
                    }
                }
            }

            Component {
                id: popListAdd
                DefaultSheet {
                    onVisibleChanged: addCompareTitle.forceActiveFocus();
                    id: popListAddSheet
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
                                id: addCompareTitle
                                placeholderText: "Title e.g. Amazon"
                            }
                        }
                        ListItem.SingleControl {
                            pressed: false
                            control: TextField {
                                id: addCompareField
                                placeholderText: "Tick Name e.g. AMZN"
                            }
                        }
                        ListItem.SingleControl {
                            pressed: false
                            control: TextField {
                                id: addCompareShares
                                placeholderText: "Number of shares"
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
                            property bool safetySwitch: true
                            control: Button {
                                text: "Add"
                                onClicked: {
                                    if (compareButton.safetySwitch) {
                                        compareButton.safetySwitch = false;
                                        statusText.text = "Searching for " + addCompareField.text
                                        var newTickTitle = addCompareTitle.text;
                                        var newTickName = addCompareField.text.toUpperCase();
                                        var err = "";
                                        if (newTickName == "" || newTickTitle == "" || addCompareShares < 0) {
                                            err = "All fields required";
                                        } else {
                                            for (var i =0; i < tickListModel.count; i++) {
                                                if (tickListModel.get(i).tickName === newTickName){
                                                    err = "Already in list: " + newTickName;
                                                }
                                            }
                                        }
                                        if (err == "") {
                                            var newTick = {};
                                            newTick["tickName"] = newTickName;
                                            newTick["name"] = newTickTitle;
                                            newTick["valuesObj"] = [];
                                            newTick["raisedPercent"] = "";
                                            newTick["numShares"] = parseInt(addCompareShares.text);
                                            newTick["volume"] = 0;
                                            newTick["normValues"] = [];
                                            newTick["tickID"] = parseInt(tickListModel.count);

                                            DataJS.testData(newTickName, function(doc){
                                                if (doc.readyState === XMLHttpRequest.DONE || doc.responseText === "") {
                                                    statusText.text = "Failed to fetch";
                                                    return false;
                                                } else {
                                                    for (var i =0; i < tickListModel.count; i++) {
                                                        if (tickListModel.get(i).tickName === newTickName){
                                                            console.log("Already in list: " + newTickName);
                                                        }
                                                    }
                                                    //tickListModel.append(newTick);
                                                    DataJS.getData(tickListModel, function(){
                                                        activityIndicator.running = false;
                                                        tickList.visible = true;
                                                        statusText.text = "ListedView Updated";
                                                        PopupUtils.close(popListAddSheet);
                                                    }, 1);
                                                }
                                            });
                                        } else {
                                            compareAddStatus.visible = true;
                                            compareAddStatus.setStatus(err);
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
            }

            Component {
                id: removeDialog
                ComposerSheet {
                    id: dialogue
                    height: parent.height
                    width: parent.height
                    title: "Remove from Tick List"


                    Label {
                        text: "Select the ones that should be removed from the list below."
                    }
                    ListEditDialog {}
                }
            }

            ListedView {
                objectName: "listedView"
            }
        }
    }

    Component.onCompleted: {
        statusText.text = "Main completed"
    }

}

import QtQuick 2.0
import Ubuntu.Components 0.1
import "data.js" as DataFile

Tab {
    title: i18n.tr("Portfolio")
    width: parent.width

    Page {
        id: plotPage
        width: parent.width

        Component.onCompleted: {
            console.log("Loading " + mainLoader.tickName);
            console.log(tickListModel.get(0).raisedPercent);
            DataFile.normalizeValues(mainLoader.tickName);
        }

        Column {
            id: singlePlotColumn
            spacing: units.gu(1)
            width: parent.width

            Canvas {
                id:canvas
                width: root.width
                height: 280
                antialiasing: true

                property string strokeStyle: "green"
                property string fillStyle: "yellow"
                property int lineWidth: 1
                property bool fill:    true
                property bool stroke:  true
                property real alpha:   1.0
                property real scaleX : 1.0
                property real scaleY : 1.0
                property real rotate : 0.0
                property real plotStep : 0.0

                onLineWidthChanged:requestPaint();
                onFillChanged:requestPaint();
                onStrokeChanged:requestPaint();
                onAlphaChanged:requestPaint();
                onScaleXChanged:requestPaint();
                onScaleYChanged:requestPaint();
                onRotateChanged:requestPaint();

                Behavior on scaleX { SpringAnimation { spring: 2; damping: 0.2; loops:Animation.Infinite } }
                Behavior on scaleY { SpringAnimation { spring: 2; damping: 0.2; loops:Animation.Infinite} }
                Behavior on rotate { SpringAnimation { spring: 2; damping: 0.2; loops:Animation.Infinite} }

                onPaint: {

                    if (!DataFile.isReady) {
                        console.log ("Loaging data");
                    } else {

                        if (canvas.plotStep === 0.0) {
                            canvas.plotStep = canvas.width / (DataFile.portfolio[plotPage.tickName].normValues.length-1);
                        }

                        var values = DataFile.portfolio[plotPage.tickName].normValues;
                        activityIndicator.running = false;

                        var ctx = canvas.getContext('2d');
                        var x = 0;
                        var y = canvas.height - values[0];

                        ctx.save();
                        var gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
                        gradient.addColorStop(0.0, "#DBF7FF");
                        gradient.addColorStop(1.0, "#B6EFFF");
                        ctx.fillStyle = gradient;
                        ctx.fillRect(0, 0, canvas.width, canvas.height);
                        ctx.strokeStyle = "#00A4D4";
                        ctx.translate(10, 10);
                        ctx.lineWidth = 2;
                        ctx.scale(canvas.scaleX-20/canvas.width, canvas.scaleY-20/canvas.height);
                        ctx.rotate(canvas.rotate);

                        // Draw plot
                        ctx.globalAlpha = 1.0;
                        ctx.lineWidth = 1.0;
                        ctx.beginPath();
                        ctx.moveTo(x , y);
                        ctx.translate(0.5,0.5);
                        for (var i = 1; i < values.length; i++) {
                            console.log(i + ": " + values[i]);
                            y = canvas.height - values[i];
                            x += canvas.plotStep;
                            ctx.lineTo(Math.round(x), y);
                        }
                        ctx.lineTo(canvas.width, canvas.height);
                        ctx.lineTo(0, canvas.height);
                        ctx.lineWidth = 1.2;
                        ctx.fillStyle = "#A2EAFF";
                        ctx.fill();
                        ctx.stroke();

                        ctx.strokeStyle = "#6CDEFF";
                        // Draw grid box
                        ctx.beginPath();
                        ctx.moveTo(0, 0);
                        ctx.lineTo(canvas.width, 0);
                        ctx.lineTo(canvas.width, canvas.height);
                        ctx.lineTo(0, canvas.height);
                        ctx.lineTo(0, 0);
                        ctx.stroke();
                        // Draw grid vertical lines
                        ctx.beginPath();
                        ctx.moveTo(canvas.width * 0.25, 0);
                        ctx.lineTo(canvas.width * 0.25, canvas.height);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.moveTo(canvas.width * 0.50, 0);
                        ctx.lineTo(canvas.width * 0.50, canvas.height);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.moveTo(canvas.width * 0.75, 0);
                        ctx.lineTo(canvas.width * 0.75, canvas.height);
                        ctx.stroke();
                        // Draw grid horizontal lines
                        ctx.beginPath();
                        ctx.moveTo(0, canvas.height * 0.25);
                        ctx.lineTo(canvas.width, canvas.height * 0.25);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.moveTo(0, canvas.height * 0.50);
                        ctx.lineTo(canvas.width, canvas.height * 0.50);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.moveTo(0, canvas.height * 0.75);
                        ctx.lineTo(canvas.width, canvas.height * 0.75);
                        ctx.stroke();

                        // Draw text
                        ctx.beginPath();
                        ctx.text((DataFile.max).toFixed(4), 0, 5);
                        ctx.text((DataFile.min*0.25 + DataFile.max*0.75).toFixed(4), 0, 5*0.75 + (canvas.height + 5)*0.25);
                        ctx.text((DataFile.min*0.5 + DataFile.max*0.5).toFixed(4), 0, 5*0.5 + (canvas.height + 5)*0.5);
                        ctx.text((DataFile.min*0.75 + DataFile.max*0.25).toFixed(4), 0, 5*0.25 + (canvas.height + 5)*0.75);
                        ctx.text((DataFile.min).toFixed(4), 0, canvas.height + 5);
                        ctx.strokeStyle = "#B6EFFF";
                        ctx.lineWidth = 3;
                        ctx.stroke();
                        ctx.fillStyle = "#00A4D4";
                        ctx.fill();

                        ctx.restore();
                    }
                }

                onCanvasSizeChanged: {
                    //canvas.plotStep = canvas.width / (DataFile.values.length-1);
                }

            } // end of canvas

            ActivityIndicator {
                id: activityIndicator
                running: true
                visible: running
                anchors.horizontalCenter: singlePlotColumn.horizontalCenter
            }
        }
    }
}

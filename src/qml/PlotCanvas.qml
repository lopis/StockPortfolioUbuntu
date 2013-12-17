import QtQuick 2.0
import "data.js" as DataFile

Canvas {
    id:canvas
    width: root.width
    height: plotPage.plotHeight
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
    property int touchX : -1
    property int touchY : -1
    property int touchIndex : -1 // updated after touchX
    property string tickID : pageStack.tickID
    property variant strokeColors : [
        "#149cdc","#77216F","#dc4814","#14dc64","#dc1445"
    ]

    function normalizeValues(model) {
        DataFile.max = 0.0;
        DataFile.min = 999999;
        DataFile.dates = [];
        DataFile.normValues = [];
        DataFile.normalizeValuesMany(model);
        canvas.plotStep = 0;
        canvas.requestPaint();
    }

    function setTouch(x, y) {
        x = x * (canvas.width / (canvas.width - 60)) - 10;
        var l = DataFile.normValues[0].length - 1;
        canvas.touchIndex = l - Math.round(l * x / canvas.width);
        canvas.touchX = canvas.width - touchIndex * canvas.plotStep;
        canvas.touchY = Math.round(canvas.plotStep * y / canvas.width) * canvas.plotStep;
        canvas.requestPaint();
    }

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
        if (!tickID || tickID == "" || tickID == undefined){
            //console.log("TickID is not defined");
            return;
        }

        if (DataFile.normValues.length < 1 ) {
            //console.log("Normalizing values for " + pageStack.tickID);
            DataFile.normalizeValuesMany(compareListModel); //tickListModel.get(tickID).valuesObj
            //console.log("Normalized count: " + DataFile.normValues[0].length);
        }

        if (canvas.plotStep === 0) {
            canvas.plotStep = canvas.width / (DataFile.normValues[0].length-1);
            //console.log("Updated plot step: " + canvas.plotStep);
        }

        var ctx = canvas.getContext('2d');

        ctx.save();
        var gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
        gradient.addColorStop(0.0, "#DBF7FF");
        gradient.addColorStop(1.0, "#B6EFFF");
        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.lineWidth = 2;
        ctx.scale(canvas.scaleX, canvas.scaleY);
        ctx.rotate(canvas.rotate);
        // Horizontal dates
        var dateX = canvas.width - 50;
        ctx.fillStyle = "#00A4D4";
        ctx.strokeStyle = "#B6EFFF";
        ctx.font = "5pt sans-serif";
        ctx.fillText(DataFile.dates[4], 0 + 10, canvas.height - 6);
        ctx.textAlign = 'center';
        ctx.fillText(DataFile.dates[3], dateX*0.25 + 15, canvas.height - 6);
        ctx.fillText(DataFile.dates[2], dateX*0.50 + 5, canvas.height - 6);
        ctx.fillText(DataFile.dates[1], dateX*0.75 - 5, canvas.height - 6);
        ctx.textAlign = 'right';
        ctx.fillText(DataFile.dates[0], dateX, canvas.height - 7);
        ctx.translate(10, 10);
        ctx.scale(canvas.scaleX-60/canvas.width, canvas.scaleY-30/canvas.height);

        // Draw plot
        ctx.globalAlpha = 1.0;
        ctx.lineWidth = 1.0;
        for (var i = 0; i < DataFile.normValues.length; i++){
            ctx.strokeStyle = strokeColors[i%strokeColors.length];
            ctx.beginPath();
            var values = DataFile.normValues[i];
            var x = 0;
            var y = canvas.height - values[0];
            ctx.moveTo(x , y);
            ctx.translate(0.5,0.5);
            //console.log(i + ") num values drawing: " + values.length);
            for (var point = 1; point < values.length; point++) {
                y = canvas.height - values[point];
                x += canvas.plotStep;
                ////console.log(i + ": " + x + ";" + y);
                ctx.lineTo(Math.round(x), y);
            }
            ctx.lineTo(canvas.width, canvas.height);
            ctx.lineTo(0, canvas.height);
            ctx.lineWidth = 1.2;
            ctx.fillStyle = "#A2EAFF";
            if(i==0) ctx.fill();
            ctx.stroke();
        }
        //console.log("Finished curves");

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

        // Draw selection lines
        if (touchIndex >= 0) {
            ctx.beginPath();
            ctx.strokeStyle = "#EE9988";
            ctx.moveTo(canvas.touchX, 0);
            ctx.lineTo(canvas.touchX, canvas.height);
            ctx.stroke();
        }

        // Draw text
        ctx.beginPath();
        // Vertical values
        ctx.text((DataFile.max).toFixed(2), 10 + canvas.width, 10);
        ctx.text((DataFile.min*0.25 + DataFile.max*0.75).toFixed(2), 10 + canvas.width, 5*0.75 + (canvas.height + 5)*0.25);
        ctx.text((DataFile.min*0.5 + DataFile.max*0.5).toFixed(2), 10 + canvas.width, 5*0.5 + (canvas.height + 5)*0.5);
        ctx.text((DataFile.min*0.75 + DataFile.max*0.25).toFixed(2), 10 + canvas.width, 5*0.25 + (canvas.height + 5)*0.75);
        ctx.text((DataFile.min).toFixed(2), 10 + canvas.width, canvas.height);
        ctx.strokeStyle = "#B6EFFF";
        ctx.lineWidth = 3;
        //ctx.stroke();
        ctx.fillStyle = "#00A4D4";
        ctx.fill();

        ctx.restore();
    }

    onCanvasSizeChanged: {
        //canvas.plotStep = canvas.width / (DataFile.values.length-1);
    }

} // end of canvas

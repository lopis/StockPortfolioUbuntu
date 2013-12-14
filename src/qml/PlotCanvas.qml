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
        "#149cdc","#dc4814","#14dc64","#dc1445","#5114dc"
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
        canvas.touchIndex = Math.round(canvas.plotStep * (canvas.width-x) / canvas.width);
        console.log("Touch detected " + "(index " + touchIndex +")");
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
            console.log("TickID is not defined");
            return;
        }

        if (DataFile.normValues.length < 1 ) {
            console.log("Normalizing values for " + pageStack.tickID);
            DataFile.normalizeValuesMany(compareListModel); //tickListModel.get(tickID).valuesObj
            console.log("Normalized count: " + DataFile.normValues[0].length);
        }

        if (canvas.plotStep === 0.0) {
            console.log("Updated plot step");
            canvas.plotStep = canvas.width / (DataFile.normValues[0].length-1);
        }

        var ctx = canvas.getContext('2d');

        ctx.save();
        var gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
        gradient.addColorStop(0.0, "#DBF7FF");
        gradient.addColorStop(1.0, "#B6EFFF");
        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.translate(10, 10);
        ctx.lineWidth = 2;
        ctx.scale(canvas.scaleX-20/canvas.width, canvas.scaleY-30/canvas.height);
        ctx.rotate(canvas.rotate);

        // Draw plot
        ctx.globalAlpha = 1.0;
        ctx.lineWidth = 1.0;

        console.log("num values drawing: " + DataFile.normValues.length);
        for (var i = 0; i < DataFile.normValues.length; i++){
            console.log("Drawing curve #" + i);
            ctx.strokeStyle = strokeColors[i%strokeColors.length];
            ctx.beginPath();
            var values = DataFile.normValues[i];
            var x = 0;
            var y = canvas.height - values[0];
            ctx.moveTo(x , y);
            ctx.translate(0.5,0.5);
            for (var point = 1; point < values.length; point++) {
                y = canvas.height - values[point];
                x += canvas.plotStep;
                //console.log(i + ": " + x + ";" + y);
                ctx.lineTo(Math.round(x), y);
            }
            ctx.lineTo(canvas.width, canvas.height);
            ctx.lineTo(0, canvas.height);
            ctx.lineWidth = 1.2;
            ctx.fillStyle = "#A2EAFF";
            if(i==0) ctx.fill();
            ctx.stroke();
        }
        console.log("Finished curves");

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
        if (touchIndex > 0) {
            ctx.beginPath();
            ctx.strokeStyle = "#8899EE";
            ctx.moveTo(canvas.touchX, 0);
            ctx.lineTo(canvas.touchX, canvas.height);
            ctx.stroke();
        }

        // Draw text
        ctx.textAlign = 'center';
        ctx.beginPath();
        // Vertical values
        ctx.text((DataFile.max).toFixed(2), 0, 5);
        ctx.text((DataFile.min*0.25 + DataFile.max*0.75).toFixed(2), 0, 5*0.75 + (canvas.height + 5)*0.25);
        ctx.text((DataFile.min*0.5 + DataFile.max*0.5).toFixed(2), 0, 5*0.5 + (canvas.height + 5)*0.5);
        ctx.text((DataFile.min*0.75 + DataFile.max*0.25).toFixed(2), 0, 5*0.25 + (canvas.height + 5)*0.75);
        ctx.text((DataFile.min).toFixed(2), 0, canvas.height + 5);
        // Horizontal dates



        ctx.strokeStyle = "#B6EFFF";
        ctx.lineWidth = 3;
        ctx.stroke();
        ctx.fillStyle = "#00A4D4";
        ctx.fill();
        ctx.fillText(DataFile.dates[0], canvas.width*0.25 - 5, canvas.height + 10);
        ctx.restore();
    }

    onCanvasSizeChanged: {
        //canvas.plotStep = canvas.width / (DataFile.values.length-1);
    }

} // end of canvas

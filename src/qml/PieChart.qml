import QtQuick 2.0
import Ubuntu.Components 0.1

Canvas {
    id: pieCanvas
    width: root.width
    height: parent.height
    antialiasing: true

    property double radius: 0
    property double margin: 0
    property double centerX: 100
    property double centerY: 100
    property string strokeStyle: "green"
    property string fillStyle: "yellow"
    property int lineWidth: 1
    property bool fill:    true
    property bool stroke:  true
    property real alpha:   1.0
    property real scaleX : 1.0
    property real scaleY : 1.0
    property real rotate : 0.0
    property variant strokeColors : [
        "#149cdc", //blue
        "#77216F", //aubergine
        "#dc4814", //orange
        "#14dc64", //green
        "#dc1445"  //pink
    ]
    property variant fillColors : [
        "#9BDFFF","#D5B0FF","#FFC1AB","#B6FFD3","#FFADC1"
    ]

    ListModel {
        id: pieListModel
    }


    function setPieChart(listModel) {
        pieListModel.clear();
        var totalShares = 0; // Total number of shares
        var values = {}; // Pairs
        for (var i = 0; i < listModel.count; i++) {
            totalShares += listModel.get(i).numShares;
        }
        console.log("totalShares: " + totalShares);
        for (i = 0; i < listModel.count; i++) {
            pieListModel.append({
                "tickName": listModel.get(i).tickName,
                "shares": listModel.get(i).numShares,
                "rads": 2*Math.PI * listModel.get(i).numShares / totalShares
            });
        }

        centerX = parent.width*0.5;
        centerY = parent.height*0.5;
        margin = 10;
        radius = parent.height * 0.5 - margin;
        pieCanvas.requestPaint();
    }

    function slice(ctx2, startRad, endRad) {

        var ctx = pieCanvas.getContext('2d');
        ctx.beginPath();
        ctx.moveTo(centerX , centerY);
        ctx.lineTo(centerX + radius*Math.cos(startRad), centerY + radius*Math.sin(startRad));
        ctx.arc(centerX , centerY, radius, startRad, endRad)
        ctx.lineTo(centerX , centerY);
        ctx.fill();
        ctx.stroke();
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
        var ctx = pieCanvas.getContext('2d');
        ctx.save();
        ctx.globalAlpha = 1.0;
        var gradient = ctx.createLinearGradient(0, 0, 0, pieCanvas.height);
        gradient.addColorStop(0.0, "#DBF7FF");
        gradient.addColorStop(1.0, "#B6EFFF");
        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, pieCanvas.width, pieCanvas.height);
        ctx.lineWidth = 1;
        ctx.scale(pieCanvas.scaleX, pieCanvas.scaleY);
        ctx.rotate(pieCanvas.rotate);
        //ctx.fillRect(0, 0, pieCanvas.width, pieCanvas.height);
        var rads = 0;
        for (var i = 0; i < pieListModel.count; i++) {
            ctx.strokeStyle = strokeColors[i];
            ctx.fillStyle = fillColors[i];
            slice(ctx, rads, rads + pieListModel.get(i).rads);

            rads += pieListModel.get(i).rads;
        }

        ctx.restore();
    }
}

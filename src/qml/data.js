// portfolio contains objects like
//    MSFT: {
//      name: Microsoft
//      valuesObj: []   // Simple array with normalized values that will be drawn
//    }
// valuesObj contains objects like
//    { date:  2013-10-18
//      open:  10.0
//      high:  10.0
//      low:   10.0
//      close: 10.0
//    }
var portfolio = {
    "MSFT": {
        "name": "Microsoft",
        "tickName": "MSFT",
        "valuesObj": [],
        "raisedPercent": 0,
        "normValues": []
    },
    "AMZN": {
        "name": "Amazon",
        "tickName": "AMZN",
        "valuesObj": [],
        "raisedPercent": 0,
        "normValues": []
    },
    "AAPL": {
        "name": "Apple",
        "tickName": "AAPL",
        "valuesObj": [],
        "raisedPercent": 0,
        "normValues": []
    }
};

var defaultNames = "MSFT,Microsoft;AMZN,Amazon;AAPL,Apple";

// max and min value calculated for the chart
var max = 0.0;
var min = 999999999;

var isReady = false;    // is true if the plot data is up to date
var isBusy = false;     // is true if the plot is being updated

// This queue will contain the tick names to be fetched.
// Use push(tickName) and pop(tickName) to add and get/remove values.
var schedule = [];

var afterReadyCall;

// The normalized Values currently being drawn
// This is an array of floats
// Each array represents a series in the plot
var normValues = [];

function normalizeValues(valuesObj, plotHeight) {
    // console.log("ValuesObj size: " + portfolio[tickName].valuesObj.length)
    for (var i = 0; i < valuesObj.count; i++) {
        if (valuesObj.get(i).close > max) {
            max = valuesObj.get(i).close;
        }
        if (valuesObj.get(i).close < min) {
            min = valuesObj.get(i).close;
        }
    }
    // console.log("max: " + max);
    // console.log("min: " + min);

    var values= [];
    if (max > 0) {
        for (i = 0; i < valuesObj.count; i++) {
            // Converts the values to a scale of [0, plotHeight]
            values.push(plotHeight * (valuesObj.get(i).close-min) / (max-min));
        }
    }
    normValues.push(values);
}

// Temporary method
function getData(afterReady) {
    // console.log("Parent width:" + root.width);
    afterReadyCall = afterReady;
    // Load the data from the file or server.
    var monthBegin = 9;
    var dayBegin = 1;
    var yearBegin = 2012;
    var monthEnd = 12;
    var dayEnd = 1;
    var yearEnd = 2013;

    for (var tickName in portfolio){
        var url = ["http://ichart.finance.yahoo.com/table.txt?",
        "a=", 		monthBegin,
        "&b=", 		dayBegin,
        "&c=", 		yearBegin,
        "&d=", 		monthEnd,
        "&e=", 		dayEnd,
        "&f=", 		yearEnd,
        "&g=d&s=", 	tickName].join("");
        loadData(tickName, url);
    }
}

function loadData(tickName, url) {
    if (!isBusy) {
        isBusy = true;
        console.log("url: " + url);
        getValues(tickName, url);
    } else {
        schedule.push([tickName, url]);
    }
}

function parseCSV(tickName, csvString) {
    // console.log("Parsing");
    var linesArray = csvString.split("\n");
    // console.log(tickName + ": Array size: " + linesArray.length);

    // Starts in line=1 to ignore CSV header
    for (var line = 1; line < linesArray.length-1; line++) {
        var lineArray = linesArray[line].split(",");
        var quote = {};
        quote["date"]  = lineArray[0];
        quote["open"]  = parseFloat(lineArray[1]);
        quote["high"]  = parseFloat(lineArray[2]);
        quote["low"]   = parseFloat(lineArray[3]);
        quote["close"] = parseFloat(lineArray[4]);
        portfolio[tickName].valuesObj.push(quote);
    }
    var curVal = portfolio[tickName].valuesObj[0].close;
    var oldVal = portfolio[tickName].valuesObj[1].close;
    portfolio[tickName].raisedPercent = (100*(curVal-oldVal)/oldVal).toFixed(2);
    // console.log(tickName + ": Parsed " + portfolio[tickName].valuesObj.length + " new values");
}

function getValues(tickName, url) {
    var doc = new XMLHttpRequest(); // Used for XML, but works for plain text or CSV
    doc.onreadystatechange = function() {
        if (doc.readyState === XMLHttpRequest.DONE) {
            parseCSV(tickName, doc.responseText);

            isBusy = false;

            if (schedule.length > 0){
                // console.log("Still busy");
                var next = schedule.pop();
                loadData(next[0], next[1], next[2]);
            } else {
                // console.log("Ready.");
                isReady = true;
                afterReadyCall();
            }
        }
    }
    doc.open("get", url);
    doc.setRequestHeader("Content-Encoding", "UTF-8");
    doc.send();
}

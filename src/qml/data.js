// Keeps a pointer to the listModel to allow
// assync return of values.
var portfolio = {listModel: {}};

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

/*
 * Will populate the listModel with
 */
function getData(listModel, afterReady) {
    portfolio.listModel = listModel;
    afterReadyCall = afterReady;
    // Load the data from the file or server.
    var monthBegin = 9;
    var dayBegin = 1;
    var yearBegin = 2012;
    var monthEnd = 12;
    var dayEnd = 1;
    var yearEnd = 2013;

    console.log("Model count: " + portfolio.listModel.count);
    for (var tickID = 0; tickID < portfolio.listModel.count; tickID++){
        console.log("TickID: " + tickID);
        var tickName = portfolio.listModel.get(tickID).tickName; //FIXME: is fixName defined?
        var url = ["http://ichart.finance.yahoo.com/table.txt?",
        "a=", 		monthBegin,
        "&b=", 		dayBegin,
        "&c=", 		yearBegin,
        "&d=", 		monthEnd,
        "&e=", 		dayEnd,
        "&f=", 		yearEnd,
        "&g=d&s=", 	tickName].join("");
        loadData(tickID, url);
    }
}

function loadData(tickID, url) {
    if (!isBusy) {
        isBusy = true;
        console.log("url: " + url);
        getValues(tickID, url);
    } else {
        schedule.push([tickID, url]);
    }
}

function getValues(tickID, url) {
    var doc = new XMLHttpRequest(); // Used for XML, but works for plain text or CSV
    doc.onreadystatechange = function() {
        if (doc.readyState === XMLHttpRequest.DONE) {
            parseCSV(tickID, doc.responseText);
            // console.log(doc.responseText);
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

function parseCSV(tickID, csvString) {
    var linesArray = csvString.split("\n");

    // Starts in line=1 to ignore CSV header
    for (var line = 1; line < linesArray.length-1; line++) {
        var lineArray = linesArray[line].split(",");
        var quote = {};
        quote["date"]  = lineArray[0];
        quote["open"]  = parseFloat(lineArray[1]);
        quote["high"]  = parseFloat(lineArray[2]);
        quote["low"]   = parseFloat(lineArray[3]);
        quote["close"] = parseFloat(lineArray[4]);
        portfolio.listModel.get(tickID).valuesObj.append(quote);
    }
    var curVal = portfolio.listModel.get(tickID).valuesObj.get(0).close;
    var oldVal = portfolio.listModel.get(tickID).valuesObj.get(1).close;
    portfolio.listModel.get(tickID).raisedPercent = (100*(curVal-oldVal)/oldVal).toFixed(2);
}

/**
 * Applications Report;
 */

info = function () {
    var ret = {}
    ret['name'] = "Applications Report";
    ret['description'] = "Monthly Report of all API token usage over time for all domains";
    ret['params'] = { start: { class: "date", default: "2009-01-01"}, end: { class: "date", default: "2014-01-01"} };
    ret['optional_params'] = {};
    scriptlet.content_type = "application/json";
    return JSON.stringify(ret)
};

run = function () {
    if (start == null || end == null) {
        scriptlet.errors = "This scriptlet requires a start and end date"
    } else {

        scriptlet.content_type = "application/csv"
        scriptlet.filename = "applications_report.csv"
        var uniqueMetricNames = {};
        var metrics = [];
        var entityId = "applications"
        var entityMetrics = JSON.parse(m.series(entityId, start, end, "MONTHLY"));
        for (var i = 0; i < entityMetrics.length; i++) {
            var s = new Date(0);
            s.setUTCSeconds(parseInt(entityMetrics[i]["start"]) / 1000);
            var e = new Date(0);
            e.setUTCSeconds(parseInt(entityMetrics[i]["end"]) / 1000);
            scriptlet.log("    range " + s + " => " + e);
            var data = entityMetrics[i]["metrics"];
            for (var name in data) {
                uniqueMetricNames[name] = ""
            }
            metrics.push([s.toISOString(), e.toISOString(), data])
        }

        var metricNames = Object.keys(uniqueMetricNames).sort();
        var output = "start, end," + metricNames.join(", ") + "\n";
        for (var row = 0; row < metrics.length; row++) {
            output = output + metrics[row][0] + ",";
            output = output + metrics[row][1] + ",";
            for (var itr = 0; itr < metricNames.length; itr++) {
                var metric = metrics[row][2][metricNames[itr]];
                if (metric) {
                    output = output + metric["value"] + ","
                } else {
                    output = output + ","
                }
            }
            output = output + "\n"

        }
        return output
    }
};
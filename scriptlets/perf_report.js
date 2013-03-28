/**
 * Internal Report; With Perf Substracted
 */
if (entity == null || start == null || end == null) {
    scriptlet.errors = "This scriptlet requires a start and end date"
} else {

scriptlet.content_type = "application/csv"
scriptlet.filename = "domain_id_" + entity + "_perf_report.csv"
var uniqueMetricNames = {};
var metrics = [];
var domainId = entity
var domainMetrics = JSON.parse(m.series(domainId, start, end, "HOURLY"));
for (var i = 0; i < domainMetrics.length; i++) {
    var s = new Date(0); s.setUTCSeconds(parseInt(domainMetrics[i]["start"]) / 1000);
    var e = new Date(0); e.setUTCSeconds(parseInt(domainMetrics[i]["end"]) / 1000);
    scriptlet.log("    range " + s + " => " + e);
    var data = domainMetrics[i]["metrics"];
    for (var name in data) {
	uniqueMetricNames[name] = ""
    }
    metrics.push([entity, s, e, data])
}

var metricNames = Object.keys(uniqueMetricNames).sort();
var output = "domain, start, end," + metricNames.join(", ") + ", browser_load_times\n";
for (var row = 0; row < metrics.length; row++) {
    output = output + metrics[row][0] + ",";
    output = output + metrics[row][1] + ",";
    output = output + metrics[row][2] + ",";
    for (var itr = 0; itr < metricNames.length; itr++) {
        var metric = metrics[row][3][metricNames[itr]];
        if (metric) {
            output = output + metric["value"] + ","
        } else {
            output = output + ","
        }
    }
    render_time = -1;
    if (metrics[row][3]['js-page-load-samples'] && metrics[row][3]['js-page-load-samples']['value'] > 0) {
	render_time = metrics[row][3]['js-page-load-time']["value"] / metrics[row][3]['js-page-load-samples']["value"];
    }
    output = output + render_time;
    output = output + "\n"

}
output

}
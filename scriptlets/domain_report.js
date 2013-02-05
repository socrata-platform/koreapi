/**
 * Domain Report; AKA: Saf Report
 */
if (start == null || end == null) {
    scriptlet.errors = "This scriptlet requires a start and end date"
} else {

scriptlet.content_type = "application/csv"
scriptlet.filename = "domain_report.csv"
var uniqueMetricNames = {};
var metrics = [];
var uniqueDomainIds = {}
for (var domainName in domains) {
    var domainId = domains[domainName];
    if (uniqueDomainIds[domainId]) {
        scriptlet.log("Already processed domain " + domainName);
        continue
    }
    uniqueDomainIds[domainId] = ""
    scriptlet.log("Working on domain " + domainName);
    var domainMetrics = JSON.parse(m.series(domainId, start, end, "MONTHLY"));
    for (var i = 0; i < domainMetrics.length; i++) {
        var s = new Date(0); s.setUTCSeconds(parseInt(domainMetrics[i]["start"]) / 1000);
        var e = new Date(0); e.setUTCSeconds(parseInt(domainMetrics[i]["end"]) / 1000);
        scriptlet.log("    range " + s + " => " + e);
        var data = domainMetrics[i]["metrics"];
        for (var name in data) {
            uniqueMetricNames[name] = ""
        }
        metrics.push([domainName, s, e, data])
    }
    scriptlet.log("Done with " + domainName)
}
var metricNames = Object.keys(uniqueMetricNames).sort();
var output = "domain, start, end," + metricNames.join(", ") + "\n";
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
    output = output + "\n"

}
output

}
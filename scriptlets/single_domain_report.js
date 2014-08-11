/**
 * Single Domain Report; AKA: Saf Report
 */

info = function () {
    var ret = {};
    ret['name'] = "Single Domain Report";
    ret['description'] = "Monthly Report of Site Metrics for a Single Domain";
    ret['params'] = { domain: {class: "domain", default: "opendata.socrata.com"}, start: { class: "date", default: "2009-01-01"}, end: { class: "date", default: "2014-01-01"} };
    // TODO: remove this afer testing
    ret['optional_params'] = { push_to_s3 : { class: "boolean", default: "false" } };
    ret['s3_bucket'] = "socrata.domain.report";
    scriptlet.content_type = "application/json";
    return JSON.stringify(ret)
};

run = function () {
    if (domain_id == null || start == null || end == null) {
        scriptlet.errors = "This scriptlet requires a start and end date and a domain name"
    } else {

        scriptlet.content_type = "application/csv"
        scriptlet.filename = "domain_id_" + domain_id + "_domain_report.csv"
        var uniqueMetricNames = {};
        var metrics = [];
        var domainId = domain_id;
        var domainMetrics = JSON.parse(m.series(domainId, start, end, "MONTHLY"));
        for (var i = 0; i < domainMetrics.length; i++) {
            var s = new Date(0);
            s.setUTCSeconds(parseInt(domainMetrics[i]["start"]) / 1000);
            var e = new Date(0);
            e.setUTCSeconds(parseInt(domainMetrics[i]["end"]) / 1000);
            scriptlet.log("    range " + s + " => " + e);
            var data = domainMetrics[i]["metrics"];
            for (var name in data) {
                uniqueMetricNames[name] = ""
            }
            metrics.push([domain_id, s.toISOString(), e.toISOString(), data])
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
        return output;
    }
};

/**
 * Internal Report; With Perf Substracted
 */

info = function () {
    var ret = {};
    ret['name'] = "Performance Report";
    ret['description'] = "Daily Report of Browser Performance Metrics";
    ret['params'] = { domain: {class: "domain", default: "opendata.socrata.com"}, start: { class: "date", default: "2013-01-01"}, end: { class: "date", default: "2014-01-01"} };
    ret['optional_params'] = {};
    scriptlet.content_type = "application/json";
    return JSON.stringify(ret)
};

run = function () {
    if (domain_id == null || start == null || end == null) {
        scriptlet.errors = "This scriptlet requires a start and end date and a domain name"
    } else {

        scriptlet.content_type = "application/csv"
        scriptlet.filename = "domain_id_" + domain_id + "_perf_report.csv"
        var uniqueMetricNames = {};
        var metrics = [];
        var domainId = domain_id + "-intern";
        var domainMetrics = JSON.parse(m.series(domainId, start, end, "DAILY"));
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
            metrics.push([s.toISOString(), e.toISOString(), data])
        }

        var metricNames = Object.keys(uniqueMetricNames).sort();
        var output = "start, end," + metricNames.join(", ") + ", ave_js_load_time, ave_dom_load_time, ave_resp_read_time, ave_resp_start_time\n";
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
            render_time = 0;
	    dom_time = 0;
	    read_time = 0;
	    start_time = 0;
            if (metrics[row][2]['js-page-load-samples'] && metrics[row][2]['js-page-load-samples']['value'] > 0) {
		if (metrics[row][2]['js-page-load-time']) {
                    render_time = metrics[row][2]['js-page-load-time']["value"] / metrics[row][2]['js-page-load-samples']["value"];
		}
		if (metrics[row][2]['js-dom-load-time']) {
                    dom_time = metrics[row][2]['js-dom-load-time']["value"] / metrics[row][2]['js-page-load-samples']["value"];
		}
		if (metrics[row][2]['js-response-read-time']) {
                    read_time = metrics[row][2]['js-response-read-time']["value"] / metrics[row][2]['js-page-load-samples']["value"];
		}
		if (metrics[row][2]['js-response-start-time']) {
                    start_time = metrics[row][2]['js-response-start-time']["value"] / metrics[row][2]['js-page-load-samples']["value"];
		}
            }
            output = output + render_time + ","  + dom_time;
            output = output + "\n"

        }
        return output

    }
};
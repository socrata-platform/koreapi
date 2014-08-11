/**
 * Views Report; views loaded for a domain
 */

info = function () {
    var ret = {};
    ret['name'] = "Dataset Views Report";
    ret['description'] = "Report of all dataset views for a domain";
    ret['params'] = { domain: {class: "domain", default: "opendata.socrata.com"},
	                    start: { class: "date", default: "2009-01-01"},
		                  end: { class: "date", default: "2014-01-01"},
		                  period: { class: "summary-type", default: "DAILY"} };
    ret['optional_params'] = {};
    scriptlet.content_type = "application/json";
    return JSON.stringify(ret)
};

runAndWriteToFile = function () {

    if (domain_id == null || start == null || end == null, period == null) {
        scriptlet.errors = "This scriptlet requires a start and end date, period, and domain name"
    } else {

        scriptlet.content_type = "application/csv"
        scriptlet.filename = "domain_id_" + domain_id + "_dataset_report.csv"
        var uniqueMetricNames = {};
        var metrics = [];
        var domainId = domain_id;
        var domainMetrics = JSON.parse(m.series("views-loaded-" + domainId, start, end, period));
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
        tempFile.write("domain, start, end," + metricNames.join(", ") + "\n");
        for (var row = 0; row < metrics.length; row++) {
            var newRow = metrics[row][0] + "," + metrics[row][1] + "," + metrics[row][2] + ",";
            for (var itr = 0; itr < metricNames.length; itr++) {
              var metric = metrics[row][3][metricNames[itr]];
              if (metric) {
                  newRow = newRow + metric["value"] + ","
              } else {
                  newRow = newRow + ","
              }
          }
          newRow = newRow + "\n"
          tempFile.write(newRow);
        }
    }
};
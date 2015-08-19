/**
 * Domain Report; AKA: Saf Report
 */

info = function () {
    var ret = {};
    ret['name'] = "Domain Report";
    ret['description'] = "Monthly Report of all Site Metrics";
    ret['params'] = { start: { class: "date", default: "2009-01-01"}, end: { class: "date", default: "2014-01-01"} };
    ret['optional_params'] = { push_to_s3 : { class: "string", default: "false" } };
    ret['s3_bucket'] = "socrata.domain.report";
    scriptlet.content_type = "application/json";
    return JSON.stringify(ret)
};

runAndWriteToFile = function () {
    if (start == null || end == null) {
        scriptlet.errors = "This scriptlet requires a start and end date"
    } else {
      scriptlet.content_type = "application/csv";
      scriptlet.filename = "domain_report.csv";
      var uniqueMetricNames = {};
      var metrics = [];
      var uniqueDomainIds = {};
      for (var domainName in domains) {
          var domainId = domains[domainName];
          if (uniqueDomainIds[domainId] != null) {
              scriptlet.log("Already processed domain " + domainName);
              continue
          }
          uniqueDomainIds[domainId] = "";
          scriptlet.log("Working on domain " + domainName);
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
              metrics.push([domainName, s.toISOString(), e.toISOString(), data])
          }
          scriptlet.log("Done with " + domainName)
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


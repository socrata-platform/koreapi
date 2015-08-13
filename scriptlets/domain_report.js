/**
 * Domain Report; AKA: Saf Report
 */

var info = function () {
    var ret = {};
    ret['name'] = "Domain Report";
    ret['description'] = "Monthly Report of all Site Metrics";
    ret['params'] = { start: { class: "date", default: "2009-01-01"}, end: { class: "date", default: "2014-01-01"} };
    ret['optional_params'] = { push_to_s3 : { class: "string", default: "false" } };
    ret['s3_bucket'] = "socrata.domain.report";
    scriptlet.content_type = "application/json";
    return JSON.stringify(ret)
};

var millisecondsFromEpochToISODateString = function(milliseconds) {
  var date = new Date(0);
  date.setUTCSeconds(parseInt(milliseconds) / 1000);
  return date.toISOString();
};

var runAndWriteToFile = function () {
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
          if (uniqueDomainIds[domainId] != null) {
              scriptlet.log("Already processed domain " + domainName);
              continue
          }
          uniqueDomainIds[domainId] = "Used to Implements Sets";

          scriptlet.log("Working on domain " + domainName);
          var domainMetrics = JSON.parse(m.series(domainId, start, end, "MONTHLY"));

          for (var i = 0; i < domainMetrics.length; i++) {
              var rangeMetrics = {};
              rangeMetrics.start = millisecondsFromEpochToISODateString(domainMetrics[i].start)
              rangeMetrics.end = millisecondsFromEpochToISODateString(domainMetrics[i].end)
              rangeMetrics.domain = domainName;

              scriptlet.log("    range " + rangeMetrics.start + " => " + rangeMetrics.end);

              var data = domainMetrics[i]["metrics"];

              if(data.length == 0) {
                continue;
              }

              for (var name in data) {
                  uniqueMetricNames[name] = "Used to Implements Sets";
                  rangeMetrics[name] = data[name]["value"];
              }

              metrics.push(rangeMetrics);
          }
          scriptlet.log("Done with " + domainName)
      }

      var metricNames = Object.keys(uniqueMetricNames).sort();
      var fields = ["domain", "start", "end"].concat(metricNames);
      fields = fields.map(function(value) {
        return { id: value };
      });

      for(var metricIndex = 0; metricIndex < metrics.length; metricIndex++){
        for(var metricNameIndex = 0; metricNameIndex < metricNames.length; metricNameIndex++) {
          if(!metrics[metricIndex][metricNames[metricNameIndex]]){
            metrics[metricIndex][metricNames[metricNameIndex]] = "";
          }
        }
      }

      tempFile.write(CSV.serialize({
        fields: fields,
        records: metrics
      },{}))
    }
};


/**
 * Domain Report; AKA: Saf Report
 */

var USED_TO_IMPLEMENT_SETS = "ANY VALUE WILL DO";

var info = function () {
    var ret = {};
    ret['name'] = "Domain Report";
    ret['description'] = "Monthly Report of all Site Metrics";
    ret['params'] = { start: { class: "date", default: "2009-01-01"}, end: { class: "date", default: "2014-01-01"} };
    ret['optional_params'] = { push_to_s3 : { class: "string", default: "false" } };
    ret['s3_bucket'] = "socrata.domain.report";
    scriptlet.content_type = "application/json";
    return JSON.stringify(ret);
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
      scriptlet.content_type = "application/csv";
      scriptlet.filename = "domain_report.csv";
      var uniqueMetricNames = {};
      var metrics = [];
      var uniqueDomainIds = {};
      for (var domainName in domains) {
          global.gc();
          var domainId = domains[domainName];
          if (uniqueDomainIds[domainId] != null) {
              scriptlet.log("Already processed domain " + domainName);
              continue
          }
          uniqueDomainIds[domainId] = USED_TO_IMPLEMENT_SETS;

          scriptlet.log("Working on domain " + domainName);
          var domainMetrics = JSON.parse(m.series(domainId, start, end, "MONTHLY"));

          for (var i = 0; i < domainMetrics.length; i++) {
              var rangeMetrics = {
                start: millisecondsFromEpochToISODateString(domainMetrics[i].start),
                end: millisecondsFromEpochToISODateString(domainMetrics[i].end),
                domain: domainName
              };

              scriptlet.log("    range " + rangeMetrics.start + " => " + rangeMetrics.end);

              var data = domainMetrics[i]["metrics"];

              for (var name in data) {
                  uniqueMetricNames[name] = USED_TO_IMPLEMENT_SETS;
                  rangeMetrics[name] = data[name]["value"];
              }

              metrics.push(rangeMetrics);
          }
          scriptlet.log("Done with " + domainName)
      }

      global.gc();

      var metricNames = Object.keys(uniqueMetricNames).map(function (value) { return value.replace(/\r?\n|\r/g, " "); }).sort();
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


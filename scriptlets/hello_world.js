info = function() {
    var ret = {}
    ret['name'] = "Hello World";
    ret['description'] = "Test Scriptlet";
    ret['params'] = { domain_id: {class: "domain_id", default: "opendata.socrata.com"}, start: { class: "date", default: "2009-01-01"}, end: { class: "date", default: "2014-01-01"}, period: { class: "summary-type", default: "DAILY"} };
    scriptlet.content_type = "application/json";
    return JSON.stringify(ret)
};

run = function() {
    scriptlet.content_type = "text/html";
    return "Hello World!" + "start: " + start + " end:  " + end + " period: "  + period + " domain_id " + domain_id
}
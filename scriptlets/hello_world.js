info = function() {
    var ret = {}
    ret['name'] = "Hello World";
    ret['description'] = "Test Scriptlet";
    ret['params'] = {};
    ret['optional_params'] = { domain: {class: "domain", default: "opendata.socrata.com"} };
    scriptlet.content_type = "application/json";
    return JSON.stringify(ret)
};

run = function() {
  scriptlet.content_type = "text/html";
  var hello = "Hello World";
  // TODO figure out why I cannot do a null check - even checking that domain_id is null throws a null exception.
  //if (domain_id == null) {
    return hello;
  //} else {
  //  return hello + " #" + domain_id;
  //}
}
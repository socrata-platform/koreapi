info = function() {
    var ret = {}
    ret['name'] = "Hello World";
    ret['description'] = "Test Scriptlet";
    ret['params'] = {};
    ret['optional_params'] = {};
    scriptlet.content_type = "application/json";
    return JSON.stringify(ret)
};

runAndWriteToFile = function() {
  tempFile.write("Hello World");
}
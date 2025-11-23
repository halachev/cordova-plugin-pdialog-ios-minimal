var exec = require('cordova/exec');

exports.init = function () {
    exec(null, null, "PDialog", "init", []);
};

exports.dismiss = function () {
    exec(null, null, "PDialog", "dismiss", []);
};

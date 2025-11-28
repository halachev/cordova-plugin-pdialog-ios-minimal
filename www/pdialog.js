cordova.define("cordova-plugin-pdialog-ios-minimal.PDialog", function(require, exports, module) {
    var exec = require('cordova/exec');

    // Оригинални методи
    exports.init = function () {
        exec(null, null, "PDialog", "init", []);
    };

    exports.dismiss = function () {
        exec(null, null, "PDialog", "dismiss", []);
    };

    // Нов метод за отваряне на галерия
    exports.openGallery = function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, "PDialog", "openGallery", []);
    };
});

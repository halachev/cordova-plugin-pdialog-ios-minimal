cordova.define("cordova-plugin-pdialog-ios-minimal.PDialog", function(require, exports, module) {
    var exec = require('cordova/exec');

    module.exports = {
        /**
         * Инициализира PDialog.
         */
        init: function() {
            exec(null, null, "PDialog", "init", []);
        },

        /**
         * Затваря текущия PDialog.
         */
        dismiss: function() {
            exec(null, null, "PDialog", "dismiss", []);
        },

        /**
         * Отваря галерията.
         * @param {function} successCallback - callback при успех
         * @param {function} errorCallback - callback при грешка
         */
        openGallery: function(successCallback, errorCallback) {
            exec(successCallback, errorCallback, "PDialog", "openGallery", []);
        }
    };
});

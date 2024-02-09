cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "cordova-plugin.SpeedCheckerPlugin",
      "file": "plugins/cordova-plugin/www/SpeedCheckerPlugin.js",
      "pluginId": "cordova-plugin",
      "clobbers": [
        "SpeedCheckerPlugin"
      ]
    }
  ];
  module.exports.metadata = {
    "cordova-plugin": "1.0.3"
  };
});
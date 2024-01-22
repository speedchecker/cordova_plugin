var exec = require('cordova/exec');

exports.startTest = function (
    onFinished,
    onError,
    onReceivedServers = function () {},
    onPingStarted = function () {},
    onPingFinished = function (obj) {},
    onDownloadStarted = function () {},
    onDownloadProgress = function (obj) {},
    onDownloadFinished = function (obj) {},
    onUploadStarted = function () {},
    onUploadProgress = function (obj) {},
    onUploadFinished = function (obj) {}
  ) {
    exec(
      function (obj) {
        var event = obj.event;
        switch (event) {
          case 'received_servers':
            onReceivedServers();
            break;
          case 'ping_started':
            onPingStarted();
            break;
          case 'ping_finished':
            onPingFinished(obj.data);
            break;
          case 'download_started':
            onDownloadStarted();
            break;
          case 'download_progress':
            onDownloadProgress(obj.data);
            break;
          case 'download_finished':
            onDownloadFinished(obj.data);
            break;
          case 'upload_started':
            onUploadStarted();
            break;
          case 'upload_progress':
            onUploadProgress(obj.data);
            break;
          case 'upload_finished':
            onUploadFinished(obj.data);
            break;
          case 'finished':
            onFinished(obj.data);
            break;
          default:
            break;
        }
      },
      function (error) {
        var errorMessage = "";
        if (Number.isInteger(error)) {
          switch (cordova.platformId) {
            case 'android':
              switch (error) {
                case 12:
                  errorMessage = "Fetching Server Failed";
                  break;
                case 16:
                  errorMessage = "ISP mismatch";
                  break;
                default:
                  errorMessage = "error code: " + error;
                  break;
              }
              break;
            case 'ios':
              switch (error) {
                case 0:
                  errorMessage = "ok";
                  break;
                case 1:
                  errorMessage = "invalid Settings";
                  break;
                case 2:
                  errorMessage = "invalid Servers";
                  break;
                case 3:
                  errorMessage = "in progress";
                  break;
                case 4:
                  errorMessage = "failed";
                  break;
                case 5:
                  errorMessage = "not saved";
                  break;
                case 6:
                  errorMessage = "cancelled";
                  break;
                case 7:
                  errorMessage = "location undefined";
                  break;
                case 8:
                  errorMessage = "app ISP mismatch";
                  break;
                default:
                  errorMessage = "error code: " + error;
                  break;
              }
              break;
            default:
              errorMessage = "error code: " + error;
              break;
          }
          console.error(errorMessage);
          onError(errorMessage);
        } else {
          console.error("The following error occurred: " + error);
          onError("The following error occurred: " + error);
        }
      },
      'SpeedCheckerPlugin',
      'startTest',
      []
    );
  };


exports.checkPermissionsAndStartTest = function (success, error) {
    exec(success, error, 'SpeedCheckerPlugin', 'checkPermissionsAndStartTest', []);
}

exports.stopTest = function (success, error) {
    exec(success, error, 'SpeedCheckerPlugin', 'stopTest', []);
}

exports.setBackgroundNetworkTestingEnabled = function (enabled, error) {
    exec(function(obj) {}, error, 'SpeedCheckerPlugin', 'setBackgroundNetworkTestingEnabled', [enabled]);
}

exports.getBackgroundNetworkTestingEnabled = function (status, error) {
    exec(function (result) { status(result) }, error, 'SpeedCheckerPlugin', 'getBackgroundNetworkTestingEnabled', []);
}

exports.getMSISDN = function (success, error) {
    exec(success, error, 'SpeedCheckerPlugin', 'getMSISDN', []);
}

exports.setMSISDN = function (value, error) {
    exec(function (obj) { }, error, 'SpeedCheckerPlugin', 'setMSISDN', [value]);
}

exports.getUserID = function (success, error) {
    exec(success, error, 'SpeedCheckerPlugin', 'getUserID', []);
}

exports.setUserID = function (value, error) {
    exec(function (obj) { }, error, 'SpeedCheckerPlugin', 'setUserID', [value]);
}

exports.getUniqueID = function (success, error) {
    exec(success, error, 'SpeedCheckerPlugin', 'getUniqueID', []);
}

exports.requestLocationPermissions = function () {
    cordova.plugins.diagnostic.getLocationAuthorizationStatus(function (status) {
        console.log("Current location permission status");
        switch (status) {
            case cordova.plugins.diagnostic.permissionStatus.NOT_REQUESTED:
                console.log("Permission not requested");
                requestLocationPermission(cordova.plugins.diagnostic.locationAuthorizationMode.WHEN_IN_USE, function (status) { requestLocationPermission(cordova.plugins.diagnostic.locationAuthorizationMode.ALWAYS); });
                break;
            case cordova.plugins.diagnostic.permissionStatus.DENIED_ALWAYS:
                console.log("Permission denied");
                break;
            case cordova.plugins.diagnostic.permissionStatus.GRANTED:
                console.log("Permission granted always");
                break;
            case cordova.plugins.diagnostic.permissionStatus.GRANTED_WHEN_IN_USE:
                console.log("Permission granted only when in use");
                requestLocationPermission(cordova.plugins.diagnostic.locationAuthorizationMode.ALWAYS);
                break;
        }
    }, function (error) {
        console.error("The following error occurred: " + error);
    });
}

function requestLocationPermission(authorizationMode, onSuccess = function(status){}) {
    cordova.plugins.diagnostic.requestLocationAuthorization(
        onSuccess,
        function(error) {
            console.error(error);
        },
        authorizationMode
    );
}
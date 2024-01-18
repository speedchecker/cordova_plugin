var exec = require('cordova/exec');

exports.startTest = function (
    onFinished,
    onError,
    onReceivedServers = function (obj) { },
    onSelectedServer = function (obj) { },
    onDownloadStarted = function () { },
    onDownloadProgress = function (obj) { },
    onDownloadFinished = function () { },
    onUploadStarted = function () { },
    onUploadProgress = function (obj) { },
    onUploadFinished = function () { },
) {
    exec(
        function (obj) {
            var event = obj.event;
            switch (event) {
                case 'received_servers':
                    onReceivedServers(obj.data);
                    break;
                case 'selected_server':
                    onSelectedServer(obj.data);
                    break;
                case 'download_started':
                    onDownloadStarted();
                    break;
                case 'download_progress':
                    onDownloadProgress(obj.data);
                    break;
                case 'download_finished':
                    onDownloadFinished();
                    break;
                case 'upload_started':
                    onUploadStarted();
                    break;
                case 'upload_progress':
                    onUploadProgress(obj.data);
                    break;
                case 'upload_finished':
                    onUploadFinished();
                    break;
                case 'finished':
                    onFinished(obj.data);
                    break;
                default:
                    break;
            }
        },
        onError,
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
};

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

exports.requestLocationPermissions = function () {
    cordova.plugins.diagnostic.getLocationAuthorizationStatus(function (status) {
        console.log("Current location permission status");
        switch (status) {
            case cordova.plugins.diagnostic.permissionStatus.NOT_REQUESTED:
                console.log("Permission not requested");
                requestLocationPermission(cordova.plugins.diagnostic.locationAuthorizationMode.WHEN_IN_USE, function (status) { requestLocationPermissions(); });
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
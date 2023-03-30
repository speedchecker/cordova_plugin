/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

// Wait for the deviceready event before using any of Cordova's device APIs.
// See https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {
    // Cordova is now initialized. Have fun!

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');
    document.getElementById("startSpeedTestButton").addEventListener("click", startSpeedTest);

    requestLocationPermissions();
}

function startSpeedTest() {
    SpeedCheckerPlugin.startTest(
        function(obj) { //onFinished
            console.log(JSON.stringify(obj));
            document.getElementById("testStatusInfo").innerHTML ='Test finished <br>Ping: ' + obj.ping + 'ms' + '<br>download speed: ' + obj.downloadSpeed.toFixed(2) + 'Mbps' + '<br>upload speed: ' + obj.uploadSpeed.toFixed(2) + 'Mbps';
        },
        function(err) { //onError
            console.log(err);
			document.getElementById("testStatusInfo").innerHTML ='error code: ' + err.code;
        },
        function(obj) { //onReceivedServers
            console.log(JSON.stringify(obj));
			document.getElementById("testStatusInfo").innerHTML ='Received servers';
        },
        function(obj) { //onSelectedServer
            console.log(JSON.stringify(obj));
			document.getElementById("testStatusInfo").innerHTML ='Selected server';
        },
        function() { //onDownloadStarted
            console.log('Download started');
			document.getElementById("testStatusInfo").innerHTML ='Download started';
        },
        function(obj) { //onDownloadProgress
            console.log(JSON.stringify(obj));
			document.getElementById("testStatusInfo").innerHTML ='Download progress: ' + obj.progress + '<br>speed: ' + obj.downloadSpeed.toFixed(2) + 'Mbps';
        },
        function() { //onDownloadFinished
            console.log('Download finished');
			document.getElementById("testStatusInfo").innerHTML ='Download finished';
        },
        function() { //onUploadStarted
            console.log('Upload started');
			document.getElementById("testStatusInfo").innerHTML ='Upload started';
        },
        function(obj) { //onUploadProgress
            console.log(JSON.stringify(obj));
			document.getElementById("testStatusInfo").innerHTML ='Upload progress: ' + obj.progress + '<br>speed: ' + obj.uploadSpeed.toFixed(2) + 'Mbps';
        },
        function() { //onUploadFinished
            console.log('Upload finished');
            document.getElementById("testStatusInfo").innerHTML ='Upload finished';
        }
    )
}

function getBackgroundNetworkTestingEnabled() {
    SpeedCheckerPlugin.getBackgroundNetworkTestingEnabled(
        function(enabled) {
            console.log('Background tests enabled: ' + enabled);
        },
        function(err) {
            console.log(err);
        }
    )
}

function setBackgroundNetworkTestingEnabled(enabled) {
    SpeedCheckerPlugin.setBackgroundNetworkTestingEnabled(
        true,
        function(err) {
            console.log(err);
        }
    )
}

function getMSISDN() {
    SpeedCheckerPlugin.getMSISDN(
        function(msisdn) {
            console.log('Current MSISDN is ' + msisdn);
        },
        function(err) {
            console.log(err);
        }
    )
}

function setMSISDN(value) {
    SpeedCheckerPlugin.setMSISDN(
        value,
        function(err) {
            console.log(err);
        }
    )
}

function removeMSISDN() {
    setMSISDN(null);
}

function getUserID() {
    SpeedCheckerPlugin.getUserID(
        function(userID) {
            console.log('Current UserID is ' + userID);
        },
        function(err) {
            console.log(err);
        }
    )
}

function setUserID(value) {
    SpeedCheckerPlugin.setUserID(
        value,
        function(err) {
            console.log(err);
        }
    )
}

function removeUserID() {
    setUserID(null);
}


function setStatus(text) {
    document.getElementById("testStatusInfo").innerHTML = text;
}

function requestLocationPermissions() {
    // For demo purpose here we request both when-in-use and always location permissions
    // You can ask user for permissions in a place that you find most appropriate regarding your app UI
    cordova.plugins.diagnostic.getLocationAuthorizationStatus(function(status){
        console.log("Current location permission status");
        switch(status){
           case cordova.plugins.diagnostic.permissionStatus.NOT_REQUESTED:
                console.log("Permission not requested");
                requestLocationPermission(cordova.plugins.diagnostic.locationAuthorizationMode.WHEN_IN_USE, function(status){ requestLocationPermissions();});
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
    }, function(error){
        console.error("The following error occurred: "+error);
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

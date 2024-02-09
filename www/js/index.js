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

    document.getElementById("start").addEventListener("click", startSpeedTest);

//Uncomment the method, for which platform you want to build a demo app. Put in this methods your license for android or ios. You
//can use both methods simultaneously if you have licenses for both platforms

    // setAndroidLicenseKey("your_android_license_key");
    // setIosLicenseKey("your_ios_license_key");
}

function startSpeedTest() {

    setStatus("Test started");
    SpeedCheckerPlugin.startTest(
        // onFinished
        function(obj) {
            console.log(JSON.stringify(obj));
            setStatus('Test finished <br>ping: ' + obj.ping +  '<br>download speed: ' + obj.downloadSpeed.toFixed(2) + ' Mbps' + '<br>upload speed: ' + obj.uploadSpeed.toFixed(2) + ' Mbps<br> jitter: ' + obj.jitter + '<br>connectionType: ' + obj.connectionType + '<br>server: ' + obj.server + '<br>ip: ' + obj.ipAddress + '<br>isp: ' + obj.ispName + '<br>timestamp: ' + obj.timestamp);
        },
        //onError
        function(error) {
            console.log(error);
            setStatus(error);
        },
        //onReceivedServers
        function(obj) {
            console.log('Finding servers started');
            setStatus('Finding servers started');
        },
        //onPingStarted
        function() {
            console.log('Ping started');
            setStatus('Ping started');
        },
        //onPingFinished
        function(obj) {
            console.log(JSON.stringify(obj));
            setStatus('Ping: ' + obj.ping.toFixed() + ' ms');
        },
        //onDownloadStarted
        function() {
            console.log('Download started');
            setStatus('Download started');
        },
        //onDownloadProgress
        function(obj) {
            console.log(JSON.stringify(obj));
            setStatus('Download progress: ' + obj.progress.toFixed(0) + ' %' + '<br>speed: ' + obj.downloadSpeed.toFixed(2) + ' Mbps');
        },
        //onDownloadFinished
        function(obj) {
            console.log(JSON.stringify(obj));
            setStatus('Download speed: ' + obj.downloadSpeed.toFixed(2) + ' Mbps');
        },
        //onUploadStarted
        function() {
            console.log('Upload started');
            setStatus('Upload started');
        },
        //onUploadProgress
        function(obj) {
            console.log(JSON.stringify(obj));
            setStatus('Upload progress: ' + obj.progress.toFixed(0) + ' %' + '<br>speed: ' + obj.uploadSpeed.toFixed(2) + ' Mbps');
        },
        //onUploadFinished
        function(obj) {
            console.log(JSON.stringify(obj));
            setStatus('Upload speed: ' + obj.uploadSpeed.toFixed(2) + ' Mbps');
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
        enabled,
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
    document.getElementById("log").innerHTML = text;
}

function setAndroidLicenseKey(value) {
    SpeedCheckerPlugin.setAndroidLicenseKey(
            value,
            function(err) {
                console.log(err);
            }
    )
}

function setIosLicenseKey(value) {
    SpeedCheckerPlugin.setIosLicenseKey(
            value,
            function(err) {
                console.log(err);
            }
    )
}

function shareBackgroundTestLogs() {
    SpeedCheckerPlugin.shareBackgroundTestLogs(
        function(err) {
            console.log(err);
        }
    )
}

function getDeviceUniqueID() {
    SpeedCheckerPlugin.getUniqueID(
        function(uniqueID) {
            console.log('Current Unique deviceID is ' + uniqueID);
        },
        function(err) {
            console.log(err);
        }
    )
}

function setSpeedTestDebugLogsEnabled(enabled) {
     SpeedCheckerPlugin.setSpeedTestDebugLogsEnabled(
         enabled,
         function(err) {
             console.log(err);
         }
     )
}


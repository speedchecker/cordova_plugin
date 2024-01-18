# Cordova plugin for Speedchecker SDK
Integrated solution with Speedchecker SDK for Cordova (Apache Cordova) and Ionic Cordova applications

## Supported platforms
* Android
* iOS

## Requirements
* Permissions:

    * ACCESS_COARSE_LOCATION
    * ACCESS_FINE_LOCATION
    * ACCESS_BACKGROUND_LOCATION

* Platform-specific requirements:
    * Android:
        *  minSDK version: 21 or higher
        *  Cordova Android version: android 11.x of higher
    * iOS:
        * Xcode 13.3.1 or later
        * Development Target 11.0 or later

## Table of contents:
* [Installing](#installing)
* [How to use](#how-to-use)
* [Uninstalling](#uninstalling)

## Installing

### 1. Create a Cordova project
```
cordova create [project folder] [your app package name] [name]
```

### 2. Go to project directory
```
cd [project folder]
```

### 3. Add your platform
````
cordova platform add android@11.0.0
````
```
cordova platform add ios
```

### 4. Add this configuration in the config.xml file of your Cordova project
* Android:
```
	<platform name="android">
        <config-file target="res/xml/config.xml" parent="/*">
            <feature name="SpeedCheckerPlugin" >
                <param name="android-package" value="org.apache.cordova.speedchecker.SpeedCheckerPlugin"/>
            </feature>
        </config-file>
        <source-file src="platforms/android/app/src/main/java/org/apache/cordova/speedchecker/SpeedCheckerPlugin.java" target-dir="src/org/apache/cordova/speedchecker" />
    </platform>
    <preference name="android-minSdkVersion" value="21" />
    <preference name="android-targetSdkVersion" value="31" />
    <preference name="android-compileSdkVersion" value="31" />

```
* iOS
```
<!--Location permission keys-->
<config-file target="*-Info.plist" parent="NSLocationAlwaysAndWhenInUseUsageDescription">
    <string>your custom text here</string>
</config-file>
<config-file target="*-Info.plist" parent="NSLocationAlwaysUsageDescription">
    <string>your custom text here</string>
</config-file>
<config-file target="*-Info.plist" parent="NSLocationWhenInUseUsageDescription">
    <string>your custom text here</string>
</config-file>

<!--Background modes key-->
<config-file target="*-Info.plist" parent="UIBackgroundModes">
    <array>
        <string>location</string>
        <string>processing</string>
    </array>
</config-file>

<!--Background test setup keys-->
<config-file target="*-Info.plist" parent="SpeedCheckerBackgroundTestEnabledOnInit">
    <true/>
</config-file>
```

### 5. Install the plugin from npm repository
````
npm i @speedchecker/cordova-plugin
````

### 6. Add the plugin to your Cordova project
````
cordova plugin add @speedchecker/cordova-plugin
````

### 7. Prepare the project
```
cordova prepare android
cordova prepare ios
```

### 8. Run or emulate the project
```
cordova run android --[your_device]
cordova run ios --[your_device]
```
```
cordova emulate android
cordova emulate ios
```

## How to use
Use the following (sample) functions in index.js:

### To start speed test by event (e.g. button click):
Plugin includes "startTest" function, which has following signature:
````
startTest = function (
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
) {...}
````
You need to implement these functions in index.js, similar to this sample function:
````
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
````
### To enable/disable background network test:
````
function setBackgroundNetworkTesting(isEnabled) {
    SpeedCheckerPlugin.setBackgroundNetworkTesting(
        isEnabled,
        function(err) {
            console.log(err);
        }
    )
}
````

### To receive background network test status:
````
function setBackgroundNetworkTesting(isEnabled) {
  SpeedCheckerPlugin.setBackgroundNetworkTesting(
    function(result) {
      console.log('Background tests enabled: ' + status);
      document.getElementById("backgroundTestInfo").innerHTML = status;
    },
    function(error) {
      console.error('Error: ' + error);
    },
    isEnabled
  );
}
````


## Uninstalling
To uninstall the plugin, run the following commands
```
npm uninstall @speedchecker/cordova-plugin
cordova plugin remove @speedchecker/cordova-plugin
```

## Badges
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
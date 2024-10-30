# Cordova plugin for Speedchecker SDK
Integrated solution with Speedchecker SDK for Cordova (Apache Cordova) and Ionic Cordova applications

## Free speed test features for your own app

SpeedChecker Cordova plugin allows developers to integrate speed test features into their own Cordova apps. You can also try our 
apps on [Google Play](https://play.google.com/store/apps/details?id=uk.co.broadbandspeedchecker\&hl=en\_US)
and [App Store](https://itunes.apple.com/app/id658790195), they are powered by the latest SpeedChecker SDK versions. More 
information about [SpeedChecker SDKs](https://www.speedchecker.com/speed-test-tools/mobile-apps-and-sdks.html)

## Features

* latency, download and upload speed of the user connection
* robust measuring of cellular, wireless and even local network
* testing details like the current speed and progress
* additional information like network type and location (see KPI list below in FAQ)
* included high-capacity servers provided and maintained by [Speedchecker](https://www.speedchecker.com) or custom servers
* detailed statistics and reports by Speedchecker

## Platform Support

| Android | iOS |
|:---:|:---:|
| supported :heavy_check_mark: | supported :heavy_check_mark: |

## Requirements

#### Android

* minSdkVersion 21
* Location permissions (for free users)
* Cordova Android version: android 11.x of higher

#### iOS

* Xcode 13.3.1 or later
* Swift 5
* Development Target 11.0 or later

## Permission requirements

Free version of the plugin requires location permission to be able to perform a speed test. You need to handle location
permission in your app level. When no location permission is given, the app will return in onError method the corresponding
message, so you need to request both Foreground and Background location permissions in your app before starting the speed test.
Check out our [location policy](https://github.com/speedchecker/cordova_plugin/wiki/Privacy-&-consent)

If you are a paid user, you should set license key before you start test. Please contact us and we will provide you with
licenseKey for your app.

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
    <preference name="android-targetSdkVersion" value="33" />
    <preference name="android-compileSdkVersion" value="33" />

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

#### To set a license key (for paid clients).

For Android licenseKey should be setup in Application onCreate method in native flutter project code.
```
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        SpeedcheckerSDK.setLicenseKey(this, "Insert your key here")
    }
}
```
For iOS use this method
```
SpeedCheckerPlugin.setIosLicenseKey(
            "your_Ioslicense_key",
            function(err) {
                console.log(err);
            }
    )
```
Licenses should be set _before_ starting the test. Make sure your package name (for Android) or bundle id (for iOS) is the same as
defined in your license agreement. You can use both methods simultaneously if you have licenses for both platforms


### To start speed test by event (e.g. button click):
Plugin includes "startTest" function, which has following signature:
````
startTest = function (
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
) {...}
````
You need to implement these functions in index.js, similar to this sample function:
````
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
````

## Uninstalling
To uninstall the plugin, run the following commands
```
npm uninstall @speedchecker/cordova-plugin
cordova plugin remove @speedchecker/cordova-plugin
```

## Demo application

Please check our [demo application](https://github.com/speedchecker/cordova_plugin/tree/demo) in Cordova which includes a 
sample app with free speed test functionality

## License

SpeedChecker is offering different types of licenses:

| Items                             | Free                          | Basic                                             | Advanced                                                          |
| --------------------------------- | ----------------------------- | ------------------------------------------------- | ----------------------------------------------------------------- |
| Speed Test Metrics                | Download / Upload / Latency   | Download / Upload / Latency / Jitter              | Download / Upload / Latency / Jitter                              |
| Accompanying Metrics              | Device / Network KPIs         | Device / Network KPIs                             | Device / Network KPIs / Advanced Cellular KPIs                    |
| Test Customization                | -                             | test duration, multi-threading, warm-up phase etc | test duration, multi-threading, warm-up phase etc                 |
| Location Permission               | Required location permissions | -                                                 | -                                                                 |
| Data Sharing Requirement          | Required data sharing         | -                                                 | -                                                                 |
| Measurement Servers               | -                             | Custom measurement servers                        | Custom measurement servers                                        |
| Background and passive collection | -                             | -                                                 | Background and Passive data collection                            |
| Cost                              | **FREE**                      | Cost: [**Enquire**](https://www.speedchecker.com/contact-us.html)                       | Cost: [**Enquire**](https://www.speedchecker.com/contact-us.html) |

## FAQ

### **Is the SDK free to use?**

Yes! But the SDK collects data on network performance from your app and shares it with Speedchecker and our clients. The free SDK version requires and
enabled location. Those restrictions are not in the Basic and Advanced versions

### **Do you have also native SDKs?**

Yes, we have both [Android](https://github.com/speedchecker/speedchecker-sdk-android) and [iOS](https://github.com/speedchecker/speedchecker-sdk-ios)
SDKs.

### **Do you provide other types of tests?**

Yes! YouTube video streaming, Voice over IP and other tests are supported by our native SDK libraries. Check out our [Android](https://github.com/speedchecker/speedchecker-sdk-android/wiki/API-documentation) and [iOS](https://github.com/speedchecker/speedchecker-sdk-ios/wiki/API-documentation) API documentation

### **Do you provide free support?**

No, we provide support only on Basic and Advanced plans

### **What are all the metrics or KPIs that you can get using our native SDKs?**

The free version of our plugin allows getting basic metrics which are described in
this [API documentation](https://github.com/speedchecker/cordova_plugin/wiki/API-documentation)

[Full list of our KPIs for Basic and Advanced versions](https://docs.speedchecker.com/measurement-methodology-links/u21ongNGAYLb6eo7cqjY/kpis-and-measurements/list-of-kpis)

### **Do you host all infrastructure for the test?**

Yes, you do not need to run any servers. We provide and maintain a network of high-quality servers and CDNs to ensure the testing is accurate. If you
wish to configure your own server, this is possible on Basic and Advanced plans.

### **How do you measure the speed?**

See
our [measurement methodology](https://docs.speedchecker.com/measurement-methodology-links/u21ongNGAYLb6eo7cqjY/kpis-and-measurements/data-collection-methodologies)

## What's next?

Please contact us for more details and license requirements.

* [More information about SpeedChecker SDKs](https://www.speedchecker.com/speed-test-tools/mobile-apps-and-sdks.html)

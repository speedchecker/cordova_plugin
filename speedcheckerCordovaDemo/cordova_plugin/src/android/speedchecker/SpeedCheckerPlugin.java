package org.apache.cordova.speedchecker;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;

import com.google.gson.JsonObject;
import com.speedchecker.android.sdk.Public.EDebug;
import com.speedchecker.android.sdk.Public.SpeedTestListener;
import com.speedchecker.android.sdk.Public.SpeedTestResult;
import com.speedchecker.android.sdk.SpeedcheckerSDK;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class SpeedCheckerPlugin extends CordovaPlugin {

    private static final int PERMISSION_LOCATION = 0;
    private static final int PERMISSION_BACKGROUND_LOCATION = 1;
    private static final String PARAMETER_EVENT = "event";
    private static final String PARAMETER_PACKETLOSS = "packetLoss";
    private static final String PARAMETER_PING = "ping";
    private static final String PARAMETER_JITTER = "jitter";
    private static final String PARAMETER_DOWNLOAD_SPEED = "downloadSpeed";
    private static final String PARAMETER_UPLOAD_SPEED = "uploadSpeed";
    private static final String PARAMETER_PROGRESS = "progress";
    private static final String PARAMETER_CITY = "city";
    private static final String PARAMETER_SERVER = "server";
    private static final String PARAMETER_CONNECTION_TYPE = "connectionType";

    private static final String[] locationPermissions = new String[]
    {
        Manifest.permission.ACCESS_COARSE_LOCATION,
        Manifest.permission.ACCESS_FINE_LOCATION
    };

    private CallbackContext callbackContext;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        EDebug.initWritableLogs(cordova.getContext());
        EDebug.l("Initialize plugin");
        SpeedcheckerSDK.init(cordova.getContext());
        SpeedcheckerSDK.SpeedTest.setOnSpeedTestListener(new SpeedTestListener() {
            @Override
            public void onTestStarted() {
                JSONObject json = new JSONObject();
                try {
                    json.put(PARAMETER_EVENT, "test_started");
                    logResult(json);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFetchServerFailed() {
                callbackContext.error("Test Server Fetch Failed");
            }

            @Override
            public void onFindingBestServerStarted() {

            }

            @Override
            public void onTestFinished(SpeedTestResult speedTestResult) {
                JSONObject result = new JSONObject();
                try {
                    result.put(PARAMETER_EVENT, "finished");
                    result.put(PARAMETER_PACKETLOSS, WebRtcCloudFlarePacketLossTest.getPacketLoss());
                    result.put(PARAMETER_PING, speedTestResult.getPing());
                    result.put(PARAMETER_DOWNLOAD_SPEED, speedTestResult.getDownloadSpeed());
                    result.put(PARAMETER_UPLOAD_SPEED, speedTestResult.getUploadSpeed());
                    result.put(PARAMETER_JITTER, speedTestResult.getJitter());
                    result.put(PARAMETER_CONNECTION_TYPE, speedTestResult.getConnectionTypeHuman());
                    result.put(PARAMETER_SERVER, speedTestResult.getServerInfo());
                    result.put(PARAMETER_CITY, speedTestResult.getCityName());
                    logResult(result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onPingStarted() {

            }

            @Override
            public void onPingFinished(int ping, int i1) {
                JSONObject result = new JSONObject();
                try {
                    result.put(PARAMETER_EVENT, "ping_finished");
                    result.put(PARAMETER_PING, ping);
                    logResult(result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onDownloadTestStarted() {

            }

            @Override
            public void onDownloadTestProgress(int progress, double downloadSpeed, double v1) {
                JSONObject result = new JSONObject();
                try {
                    result.put(PARAMETER_EVENT, "download_progress");
                    result.put(PARAMETER_DOWNLOAD_SPEED, downloadSpeed);
                    result.put(PARAMETER_PROGRESS, progress);
                    logResult(result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onDownloadTestFinished(double v) {

            }

            @Override
            public void onUploadTestStarted() {

            }

            @Override
            public void onUploadTestProgress(int progress, double uploadSpeed, double v1) {
                JSONObject result = new JSONObject();
                try {
                    result.put(PARAMETER_EVENT, "upload_progress");
                    result.put(PARAMETER_UPLOAD_SPEED, uploadSpeed);
                    result.put(PARAMETER_PROGRESS, progress);
                    logResult(result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onUploadTestFinished(double v) {

            }

            @Override
            public void onTestWarning(String s) {

            }

            @Override
            public void onTestFatalError(String s) {
                callbackContext.error(s);
            }

            @Override
            public void onTestInterrupted(String s) {
                callbackContext.error(s);
            }
        });
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        // add permission validation
        if ("checkPermissionsAndStartTest".equals(action)) {
            EDebug.l("request permissions");
            this.callbackContext = callbackContext;
            checkPermissionsAndStartTest();
            return true;
        } else if ("startTest".equals(action)) {
            EDebug.l("Start SpeedTest");
            this.callbackContext = callbackContext;
            SpeedcheckerSDK.SpeedTest.startTest(cordova.getContext());
            WebRtcCloudFlarePacketLossTest.start(cordova.getContext());
            return true;
        } else if ("shareBackgroundTestLogs".equals(action)) {
            EDebug.sendLogFiles(cordova.getActivity());
            return true;
        } else if ("setBackgroundNetworkTestingEnabled".equals(action)) {
            if(args.getBoolean(0)) {
                SpeedcheckerSDK.setBackgroundNetworkTesting(cordova.getActivity(), true);
            } else {
                SpeedcheckerSDK.setBackgroundNetworkTesting(cordova.getActivity(), false);
            }
            return true;
        } else if ("getBackgroundNetworkTestingEnabled".equals(action)) {
            callbackContext.success(String.valueOf(SpeedcheckerSDK.isBackgroundNetworkTesting(cordova.getActivity())));
            return true;
        } else if ("setMSISDN".equals(action)) {
            SpeedcheckerSDK.setMSISDN(cordova.getActivity(), args.getString(0));
            return true;
        } else if ("setUserId".equals(action)) {
            SpeedcheckerSDK.setUserId(cordova.getActivity(), args.getString(0));
            return true;
        } else if ("stopTest".equals(action)) {
            SpeedcheckerSDK.SpeedTest.interruptTest();
            return true;
        } else if ("isAllowedLocation".equals(action)) {
            callbackContext.success(String.valueOf(isLocationBasePermissionGranted()));
            return true;
        } else if ("isAllowedBackgroundLocation".equals(action)) {
            callbackContext.success(String.valueOf(isLocationBackgroundPermissionGranted()));
            return true;
        } else if ("requestLocationPermission".equals(action)) {
            this.callbackContext = callbackContext;
            cordova.requestPermissions(this, PERMISSION_LOCATION, locationPermissions);
            return true;
        } else if ("requestBackgroundLocationPermission".equals(action)) {
            this.callbackContext = callbackContext;
            cordova.requestPermission(this, PERMISSION_BACKGROUND_LOCATION, Manifest.permission.ACCESS_BACKGROUND_LOCATION);
            return true;
        } else {
            return false;
        }
    }

    // Add To permisssion request
    public void checkPermissionsAndStartTest() {
        if (isLocationBasePermissionGranted()) {
            if (!isLocationBackgroundPermissionGranted()) {
                cordova.requestPermission(this, PERMISSION_BACKGROUND_LOCATION, Manifest.permission.ACCESS_BACKGROUND_LOCATION);
            }
        } else {
            cordova.requestPermissions(this, PERMISSION_LOCATION, locationPermissions);
        }
    }

    private void logResult(JSONObject result) {
        PluginResult progressResult = new PluginResult(PluginResult.Status.OK, result);
        progressResult.setKeepCallback(true);
        callbackContext.sendPluginResult(progressResult);
    }

    private boolean isLocationBasePermissionGranted() {
        return cordova.hasPermission(Manifest.permission.ACCESS_COARSE_LOCATION) && cordova.hasPermission(Manifest.permission.ACCESS_FINE_LOCATION);
    }

    private boolean isLocationBackgroundPermissionGranted() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return cordova.hasPermission(Manifest.permission.ACCESS_BACKGROUND_LOCATION);
        } else {
            return true;
        }
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        boolean success = true;
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED) {
                success = false;
                break;
            }
        }
        if (success) {
            checkPermissionsAndStartTest();
            callbackContext.success("OK");
        } else {
            callbackContext.error("Permission denied.");
        }
    }
}
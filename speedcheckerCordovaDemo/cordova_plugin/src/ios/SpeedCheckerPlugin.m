/********* SpeedCheckerPlugin.m Cordova Plugin Implementation *******/

#import "SpeedCheckerPlugin.h"
#import <Cordova/CDV.h>
#import "AppDelegate+SpeedCheckerPlugin.h"
@import SpeedcheckerSDK;
@import CoreLocation;


typedef enum {
    InternetSpeedTestEventReceivedServers,
    InternetSpeedTestEventSelectedServer,
    InternetSpeedTestEventDownloadStarted,
    InternetSpeedTestEventDownloadProgress,
    InternetSpeedTestEventDownloadFinished,
    InternetSpeedTestEventUploadStarted,
    InternetSpeedTestEventUploadProgress,
    InternetSpeedTestEventUploadFinished,
    InternetSpeedTestEventFinished
} InternetSpeedTestEvent;


@interface SpeedCheckerPlugin () <InternetSpeedTestDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) InternetSpeedTest *internetTest;

@property (nonatomic, strong) CDVInvokedUrlCommand *command;

@end

@implementation SpeedCheckerPlugin

#pragma mark - Init

- (void)pluginInitialize {
    [super pluginInitialize];
}

#pragma mark - Commands

- (void)startTest:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count == 0) {
        self.command = command;
        [self checkPermissionsAndStartTest];
    } else {
        self.command = nil;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)stopTest:(CDVInvokedUrlCommand*)command {
    if (self.internetTest) {
        [self.internetTest forceFinish:^(enum SpeedTestError error) {
            if (error != SpeedTestErrorOk) {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:(int)error];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } else {
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
            }
        }];
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    }
}

- (void)getBackgroundNetworkTestingEnabled:(CDVInvokedUrlCommand*)command {
    BOOL testsEnabled = [[AppDelegate instance] getBackgroundNetworkTestingEnabled];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:testsEnabled];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setBackgroundNetworkTestingEnabled:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count == 1 && [command.arguments[0] isKindOfClass:[NSNumber class]]) {
        BOOL testsEnabled = [command.arguments[0] boolValue];
        [[AppDelegate instance] setBackgroundNetworkTestingEnabled:testsEnabled];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)getMSISDN:(CDVInvokedUrlCommand*)command {
    NSString *msisdn = [InternetSpeedTest msisdn];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msisdn];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setMSISDN:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count == 1 && ([command.arguments[0] isKindOfClass:[NSString class]] || [command.arguments[0] isEqual:[NSNull null]])) {
        NSString *msisdn = [self objectOrNil:command.arguments[0]];
        [InternetSpeedTest setMsisdn:msisdn];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)getUserID:(CDVInvokedUrlCommand*)command {
    NSString *userID = [InternetSpeedTest userID];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:userID];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUserID:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count == 1 && ([command.arguments[0] isKindOfClass:[NSString class]] || [command.arguments[0] isEqual:[NSNull null]])) {
        NSString *userID = [self objectOrNil:command.arguments[0]];
        [InternetSpeedTest setUserID:userID];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)shareBackgroundTestLogs:(CDVInvokedUrlCommand*)command {
    UIViewController *viewController = [AppDelegate instance].viewController;
    [BackgroundTest shareLogsFromViewController:viewController presentationSourceView:viewController.view];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

#pragma mark - Helpers

- (void)checkPermissionsAndStartTest {
    SCLocationHelper *locationHelper = [[SCLocationHelper alloc] init];
    [locationHelper locationServicesEnabled:^(BOOL locationEnabled) {
        if (!locationEnabled) {
            [self sendErrorResult:SpeedTestErrorLocationUndefined];
            return;
        }

        [self startSpeedTest];
    }];
}

- (void)startSpeedTest {
    self.internetTest = [[InternetSpeedTest alloc] initWithIsBackground:NO delegate:self];
    [self.internetTest start:^(enum SpeedTestError error) {
        if (error != SpeedTestErrorOk) {
            NSLog(@"Error %ld", (long)error);
            [self sendErrorResult:error];
        }
    }];
}

- (void)sendErrorResult:(SpeedTestError)error {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:(int)error];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

- (void)sendEvent:(InternetSpeedTestEvent)event data:(NSDictionary*)data {
    NSString *eventName = [self getNameForEvent:event];
    NSDictionary *dict = @{ @"event": eventName, @"data": [self objectOrNull:data]};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
    if (event != InternetSpeedTestEventFinished) {
        [pluginResult setKeepCallbackAsBool:YES];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

- (NSString*)getNameForEvent:(InternetSpeedTestEvent)event {
    switch (event) {
         case InternetSpeedTestEventReceivedServers:
            return @"received_servers";
        case InternetSpeedTestEventSelectedServer:
            return @"selected_server";
        case InternetSpeedTestEventDownloadStarted:
            return @"download_started";
        case InternetSpeedTestEventDownloadProgress:
            return @"download_progress";
        case InternetSpeedTestEventDownloadFinished:
            return @"download_finished";
        case InternetSpeedTestEventUploadStarted:
            return @"upload_started";
        case InternetSpeedTestEventUploadProgress:
            return @"upload_progress";
        case InternetSpeedTestEventUploadFinished:
            return @"upload_finished";
        case InternetSpeedTestEventFinished:
            return @"finished";
        // case InternetSpeedTestEventError:
        //     return @"error";
        default:
            break;
    }
    return @"";
}

- (id)objectOrNull:(id)object {
  return object ?: [NSNull null];
}

- (id)objectOrNil:(id)object {
    return [object isEqual:[NSNull null]] ? nil : object;
}

- (NSDictionary*)getServerDict:(SpeedTestServer*)server {
    NSDictionary *serverDict = @{ @"scheme": [self objectOrNull:server.scheme],
                                  @"domain": [self objectOrNull:server.domain],
                                  @"countryCode": [self objectOrNull:server.countryCode],
                                  @"cityName": [self objectOrNull:server.cityName],
                                  @"country": [self objectOrNull:server.country] };
    return serverDict;
}

- (NSDictionary*)getResultDict:(SpeedTestResult*)result {
    NSNumber *timestamp;
    if (result.date) {
        timestamp = [NSNumber numberWithDouble:[result.date timeIntervalSince1970]];
    }
    NSNumber *packetLossPercentage;
    if (result.packetLoss) {
        packetLossPercentage = [NSNumber numberWithDouble:result.packetLoss.packetLoss];
    }
    NSDictionary *dict = @{ @"connectionType": [self getNetworkDict:result.network],
                            @"server": [self getServerDict:result.server],
                            @"ping": [NSNumber numberWithInteger:result.latencyInMs],
                            @"jitter": [NSNumber numberWithDouble:result.jitter],
                            @"downloadSpeed": [NSNumber numberWithDouble:result.downloadSpeed.mbps],
                            @"uploadSpeed": [NSNumber numberWithDouble:result.uploadSpeed.mbps],
                            @"timeToFirstByteMs": [NSNumber numberWithInteger:result.timeToFirstByteMs],
                            @"packetLoss": [self objectOrNull:packetLossPercentage],
                            @"ipAddress": [self objectOrNull:result.ipAddress],
                            @"ispName": [self objectOrNull:result.ispName],
                            @"timestamp": [self objectOrNull:timestamp],
                            @"city": [self objectOrNull:result.userCityName]};
    return dict;
}

- (NSDictionary*)getNetworkDict:(SpeedTestNetwork*)network {
    NSString *typeString = @"any";
    switch (network.type) {
         case SpeedTestNetworkTypeWifi:
            typeString = @"wifi";
            break;
        case SpeedTestNetworkTypeCellular:
            typeString = @"cellular";
            break;
        default:
            break;
    }
     NSDictionary *dict = @{ @"type": [self objectOrNull:typeString],
                             @"cellularTechnology": [self objectOrNull:network.cellularTechnology],
                             @"networkShortDescription": [self objectOrNull:network.networkShortDescription]};
     return dict;
}



- (void)requestPermissions:(CDVInvokedUrlCommand*)command {
    self.locationManager = [CLLocationManager new];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (CLLocationManager.locationServicesEnabled) {
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager requestAlwaysAuthorization];
            [self.locationManager startUpdatingLocation];
        }
    });
}


- (void)stopMonitoringLocation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.locationManager stopUpdatingLocation];
    });
}

#pragma mark - InternetSpeedTestDelegate

- (void)internetTestErrorWithError:(enum SpeedTestError)error {
    [self sendErrorResult:error];
    NSLog(@"Error %ld", (long)error);
}

- (void)internetTestFinishWithResult:(SpeedTestResult *)result {
    [self sendEvent:InternetSpeedTestEventFinished data:[self getResultDict:result]];
}

- (void)internetTestReceivedWithServers:(NSArray<SpeedTestServer *> *)servers {
    NSMutableArray *serversArray = [NSMutableArray new];
    for (SpeedTestServer *server in servers) {
        NSDictionary *serverDict = [self getServerDict:server];
        [serversArray addObject:serverDict];
    }
    [self sendEvent:InternetSpeedTestEventReceivedServers data: @{@"servers": serversArray}];
}

- (void)internetTestSelectedWithServer:(SpeedTestServer *)server latency:(NSInteger)latency jitter:(NSInteger)jitter {
    NSDictionary *serverDict = [self getServerDict:server];
    NSDictionary *data = @{ @"server": serverDict,
                            @"ping": [NSNumber numberWithInteger:latency],
                            @"jitter":  [NSNumber numberWithInteger:jitter]};
    [self sendEvent:InternetSpeedTestEventSelectedServer data:data];
}

- (void)internetTestDownloadStart {
    [self sendEvent:InternetSpeedTestEventDownloadStarted data:nil];
}

- (void)internetTestDownloadFinish {
    [self sendEvent:InternetSpeedTestEventDownloadFinished data:nil];    
}

- (void)internetTestDownloadWithProgress:(double)progress speed:(SpeedTestSpeed *)speed {
    NSDictionary *data = @{ @"progress": [NSNumber numberWithDouble:progress],
                            @"downloadSpeed": [NSNumber numberWithDouble:speed.mbps]};
    [self sendEvent:InternetSpeedTestEventDownloadProgress data:data];
}

- (void)internetTestUploadStart {
    [self sendEvent:InternetSpeedTestEventUploadStarted data:nil];
}

- (void)internetTestUploadFinish {
    [self sendEvent:InternetSpeedTestEventUploadFinished data:nil];
}

- (void)internetTestUploadWithProgress:(double)progress speed:(SpeedTestSpeed *)speed {
    NSDictionary *data = @{ @"progress": [NSNumber numberWithDouble:progress],
                            @"uploadSpeed": [NSNumber numberWithDouble:speed.mbps]};
    [self sendEvent:InternetSpeedTestEventUploadProgress data:data];
}

@end

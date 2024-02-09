/********* SpeedCheckerPlugin.m Cordova Plugin Implementation *******/

#import "SpeedCheckerPlugin.h"
#import <Cordova/CDV.h>
#import "AppDelegate+SpeedCheckerPlugin.h"
@import SpeedcheckerSDK;


typedef enum {
    InternetSpeedTestEventReceivedServers,
    InternetSpeedTestEventPingStarted,
    InternetSpeedTestEventPingFinished,
    InternetSpeedTestEventDownloadStarted,
    InternetSpeedTestEventDownloadProgress,
    InternetSpeedTestEventDownloadFinished,
    InternetSpeedTestEventUploadStarted,
    InternetSpeedTestEventUploadProgress,
    InternetSpeedTestEventUploadFinished,
    InternetSpeedTestEventFinished
} InternetSpeedTestEvent;


@interface SpeedCheckerPlugin () <InternetSpeedTestDelegate>

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
    self.command = command;
    [self startSpeedTest];
}

- (void)stopTest:(CDVInvokedUrlCommand*)command {
    if (self.internetTest) {
        [self.internetTest forceFinish:^(enum SpeedTestError error) {
            if (error != SpeedTestErrorOk) {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:(int)error];
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

- (void)shareBackgroundTestLogs:(CDVInvokedUrlCommand*)command {
    UIViewController *viewController = [AppDelegate instance].viewController;
    [BackgroundTest shareLogsFromViewController:viewController presentationSourceView:viewController.view];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)setSpeedTestDebugLogsEnabled:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count == 1 && [command.arguments[0] isKindOfClass:[NSNumber class]]) {
        BOOL logsEnabled = [command.arguments[0] boolValue];
        InternetSpeedTest.debugLogsEnabled = logsEnabled;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

#pragma mark - Helpers

- (void)startSpeedTest {
    NSString *licenseKey = [AppDelegate instance].licenseKey;
    self.internetTest = [[InternetSpeedTest alloc] initWithLicenseKey:licenseKey delegate:self];
    
    typedef void (^SpeedTestCompletionHandler)(enum SpeedTestError error);
    SpeedTestCompletionHandler completionHandler = ^(enum SpeedTestError error) {
        if (error != SpeedTestErrorOk) {
            [self sendErrorResult:error];
        }
    };
    
    if ([self isStringNilOrEmpty:licenseKey]) {
        [self.internetTest startFreeTest:completionHandler];
    } else {
        [self.internetTest start:completionHandler];
    }
}

- (void)sendErrorResult:(SpeedTestError)error {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:(int)error];
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
        case InternetSpeedTestEventPingStarted:
            return @"ping_started";
        case InternetSpeedTestEventPingFinished:
            return @"ping_finished";
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

- (BOOL)isStringNilOrEmpty:(NSString *)string {
    return !string || [string isEqualToString:@""] || string.length == 0;
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

#pragma mark - InternetSpeedTestDelegate

- (void)internetTestErrorWithError:(enum SpeedTestError)error {
    [self sendErrorResult:error];
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
    if (serversArray.count > 0) {
        [self sendEvent:InternetSpeedTestEventPingStarted data:nil];
    }
}

- (void)internetTestSelectedWithServer:(SpeedTestServer *)server latency:(NSInteger)latency jitter:(NSInteger)jitter {
    NSDictionary *serverDict = [self getServerDict:server];
    NSDictionary *data = @{ @"server": serverDict,
                            @"ping": [NSNumber numberWithInteger:latency],
                            @"jitter":  [NSNumber numberWithInteger:jitter]};
    [self sendEvent:InternetSpeedTestEventPingFinished data:data];
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

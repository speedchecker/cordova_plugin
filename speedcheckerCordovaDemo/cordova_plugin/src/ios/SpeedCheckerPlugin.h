
#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpeedCheckerPlugin : CDVPlugin
  - (void)requestPermissions:(CDVInvokedUrlCommand*)command;
  - (void)startTest:(CDVInvokedUrlCommand*)command;
  - (void)stopTest:(CDVInvokedUrlCommand*)command;
  - (void)getBackgroundNetworkTestingEnabled:(CDVInvokedUrlCommand*)command;
  - (void)setBackgroundNetworkTestingEnabled:(CDVInvokedUrlCommand*)command;
  - (void)getMSISDN:(CDVInvokedUrlCommand*)command;
  - (void)setMSISDN:(CDVInvokedUrlCommand*)command;
  - (void)getUserID:(CDVInvokedUrlCommand*)command;
  - (void)setUserID:(CDVInvokedUrlCommand*)command;
  - (void)shareBackgroundTestLogs:(CDVInvokedUrlCommand*)command;
@end

NS_ASSUME_NONNULL_END
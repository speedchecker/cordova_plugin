
#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpeedCheckerPlugin : CDVPlugin
  - (void)startTest:(CDVInvokedUrlCommand*)command;
  - (void)stopTest:(CDVInvokedUrlCommand*)command;
  - (void)getBackgroundNetworkTestingEnabled:(CDVInvokedUrlCommand*)command;
  - (void)setBackgroundNetworkTestingEnabled:(CDVInvokedUrlCommand*)command;
  - (void)shareBackgroundTestLogs:(CDVInvokedUrlCommand*)command;
@end

NS_ASSUME_NONNULL_END

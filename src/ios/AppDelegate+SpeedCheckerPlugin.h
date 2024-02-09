#import "AppDelegate.h"

@interface AppDelegate (SpeedCheckerPlugin) <UIApplicationDelegate>
- (BOOL)getBackgroundNetworkTestingEnabled;
- (void)setBackgroundNetworkTestingEnabled:(BOOL)testsEnabled;
- (NSString* _Nullable)licenseKey;
+ (AppDelegate *_Nonnull) instance;
@end

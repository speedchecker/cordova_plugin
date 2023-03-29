#import "AppDelegate.h"

@interface AppDelegate (SpeedCheckerPlugin) <UIApplicationDelegate>
- (BOOL)getBackgroundNetworkTestingEnabled;
- (void)setBackgroundNetworkTestingEnabled:(BOOL)testsEnabled;
+ (AppDelegate *_Nonnull) instance;
@end

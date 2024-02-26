#import "AppDelegate+SpeedCheckerPlugin.h"
#import <objc/runtime.h>
@import SpeedcheckerSDK;
@import CoreLocation;

@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) BackgroundTest *backgroundTest;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

static NSString *const kBackgroundTestEnabledOnInit = @"SpeedCheckerBackgroundTestEnabledOnInit";
static NSString *const kBackgroundTestUsed = @"SpeedCheckerBackgroundTestUsed";
static NSString *const kBackgroundConfigURL = @"SpeedCheckerBackgroundConfigURL";
static NSString *const kSpeedCheckerLicenseKey = @"SpeedCheckerLicenseKey";

#define kBackgroundTest @"kBackgroundTest"
#define kLocationManager @"kLocationManager"

@implementation AppDelegate (SpeedCheckerPlugin)

static AppDelegate* instance;

+ (AppDelegate*) instance {
    return instance;
}

+ (void)load {
    Method original = class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    Method swizzled = class_getInstanceMethod(self, @selector(application:speedcheckerSwizzledDidFinishLaunchingWithOptions:));
    method_exchangeImplementations(original, swizzled);
}

- (BOOL)application:(UIApplication *)application speedcheckerSwizzledDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self application:application speedcheckerSwizzledDidFinishLaunchingWithOptions:launchOptions];
    
    instance = self;

    if (!self.backgroundTestUsed) {
        // skip background test setup
        return YES;
    }
    
    // Init BackgroundTest
    if (self.backgroundTest == nil) {
        self.backgroundTest = [[BackgroundTest alloc] initWithLicenseKey:self.licenseKey url:self.backgroundConfigURL testsEnabled:self.testStartOnInit];
    }
    
    // Load your configuration
    [self.backgroundTest loadConfigWithLaunchOptions:launchOptions completion:^(BOOL success) {
        // Handle case if configuration was not loaded successfully
    }];
    
    // Setup location manager
    if (launchOptions[UIApplicationLaunchOptionsLocationKey] != nil || self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    
    [self.backgroundTest prepareLocationManagerWithLocationManager:self.locationManager];
    
    // Register BGProcessingTask
    [self.backgroundTest registerBGTask:self.locationManager];

    return YES;
}

- (BOOL)getBackgroundNetworkTestingEnabled {
    return [self.backgroundTest getBackgroundNetworkTestingEnabled];
}

- (void)setBackgroundNetworkTestingEnabled:(BOOL)testsEnabled {
    [self.backgroundTest setBackgroundNetworkTestingWithTestsEnabled:testsEnabled];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self.backgroundTest didChangeAuthorizationWithManager:manager status:status];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.backgroundTest didUpdateLocationsWithManager:manager locations:locations];
}

#pragma mark - Getters/Setters

- (void)setBackgroundTest:(BackgroundTest*)backgroundTest {
    objc_setAssociatedObject(self, kBackgroundTest, backgroundTest, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BackgroundTest*)backgroundTest {
    return objc_getAssociatedObject(self, kBackgroundTest);
}

- (void)setLocationManager:(CLLocationManager*)locationManager {
    objc_setAssociatedObject(self, kLocationManager, locationManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CLLocationManager*)locationManager {
    return objc_getAssociatedObject(self, kLocationManager);
}

- (BOOL)testStartOnInit {
    id startTest = [[NSBundle mainBundle] objectForInfoDictionaryKey:kBackgroundTestEnabledOnInit];
    if (startTest) {
        if ([startTest isKindOfClass:[NSNumber class]]) {
            return [startTest boolValue];
        }
        return NO;
    } else {
        // if no value in Info.plist, default to YES
        return YES;
    }
}
- (BOOL)backgroundTestUsed {
    id testUsed = [[NSBundle mainBundle] objectForInfoDictionaryKey:kBackgroundTestUsed];
    if (testUsed && [testUsed isKindOfClass:[NSNumber class]]) {
        return [testUsed boolValue];
    }
    return NO;
}

- (NSString*)licenseKey {
    id key = [[NSBundle mainBundle] objectForInfoDictionaryKey:kSpeedCheckerLicenseKey];
    if ([key isKindOfClass:[NSString class]]) {
        return key;
    }
    return nil;
}

- (NSString*)backgroundConfigURL {
    id configURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:kBackgroundConfigURL];
    if ([configURL isKindOfClass:[NSString class]]) {
        return configURL;
    }
    return nil;
}

@end

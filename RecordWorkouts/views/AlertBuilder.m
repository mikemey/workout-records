#import "AlertBuilder.h"
#import <HealthKit/HKTypeIdentifiers.h>

@implementation AlertBuilder {
    UIAlertController *alert;
}

+ (void) showErrorAlertOn: (UIViewController *)delegate title:(NSString *)title error: (NSError *)error {
    NSString *message = error.code == HKErrorAuthorizationDenied
    ? @"Please enable access in\nSettings -> Privacy -> Health"
    : error.userInfo[NSLocalizedDescriptionKey];
    AlertBuilder *alertBuilder = [[AlertBuilder alloc] init:title message:message];
    [alertBuilder addOKAction];
    [alertBuilder show:delegate];
}

- (id) init: (NSString *)title message: (NSString *)message {
    self = [super init];
    
    alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    return self;
}

- (void) show: (UIViewController *)target {
    [target presentViewController:alert animated:YES completion:nil];
}

- (void) addDefaultAction: (NSString *)title handler: (void (^)(UIAlertAction * action))handler {
    UIAlertAction* action = [UIAlertAction actionWithTitle:title
                                                     style:UIAlertActionStyleDefault
                                                   handler:handler];
    [alert addAction:action];
}

- (void) addOKAction {
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
}

- (void) addCancelAction {
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
}

@end

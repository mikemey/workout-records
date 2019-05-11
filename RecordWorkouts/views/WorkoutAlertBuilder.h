#import <Foundation/Foundation.h>

@interface WorkoutAlertBuilder:NSObject {}

- (id) init: (UIViewController  *)target title:(NSString *)title message:(NSString *)message;
- (void) show;

- (void) addDefaultAction: (NSString *)title handler:(void (^)(UIAlertAction * action))handler;
- (void) addOKAction;
- (void) addCancelAction;
@end

@implementation WorkoutAlertBuilder
UIViewController *_target;
UIAlertController *alert;

- (id) init: (UIViewController  *)target title:(NSString *)title message:(NSString *)message {
    self = [super init];
    
    _target = target;
    alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    return self;
}

- (void) show {
    [_target presentViewController:alert animated:YES completion:nil];
}

- (void) addDefaultAction: (NSString *)title handler:(void (^)(UIAlertAction * action))handler {
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

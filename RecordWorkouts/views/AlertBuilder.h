#import <UIKit/UIKit.h>

@interface AlertBuilder:NSObject {}
+ (void) showErrorAlertOn: (id)delegate title:(NSString *)title error: (NSError *)error;

- (id) init: (NSString *)title message: (NSString *)message;
- (void) show: (UIViewController  *)target;

- (void) addDefaultAction: (NSString *)title handler: (void (^)(UIAlertAction * action))handler;
- (void) addOKAction;
- (void) addCancelAction: (void (^)(UIAlertAction * action))handler;
@end

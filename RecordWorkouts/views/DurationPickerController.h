#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DurationPickerController : NSObject {}

- (id) init: (UITextField *) field
    toolbar: (UIToolbar *) toolbar
   callback: (void (^)(NSTimeInterval)) callback;
- (void) setInitialDuration: (NSTimeInterval) date;
@end

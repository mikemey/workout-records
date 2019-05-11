#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DatePickerController : NSObject {}

- (id) init: (UITextField *) field
    toolbar: (UIToolbar *) toolbar
   callback: (void (^)(NSDate *)) callback;
- (void) setNewDate: (NSDate *) date;
@end

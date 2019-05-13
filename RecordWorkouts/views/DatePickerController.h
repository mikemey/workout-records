#import <UIKit/UIKit.h>
#import "ToolbarBuilder.h"

@interface DatePickerController : NSObject {}

- (id) init: (UITextField *)field
toolbarBuilder: (ToolbarBuilder *)toolbarBuilder
   callback: (void (^)(NSDate *))callback;
- (void) setDateNow;
@end

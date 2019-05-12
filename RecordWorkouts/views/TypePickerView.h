#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@interface TypePickerView : UIPickerView {
    void (^_callbackHandler)(HKQuantityTypeIdentifier typeId);
}

- (id) init: (UITextField *) field
    toolbar:(UIToolbar *) toolbar
   callback:(void (^)(HKQuantityTypeIdentifier)) callback;
- (void) setNewActivity:(NSInteger) index;
@end

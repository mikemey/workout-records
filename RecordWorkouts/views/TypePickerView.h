#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>
#import "WRFormat.h"

@interface TypePickerView : UIPickerView {
    void (^_callbackHandler)(HKQuantityTypeIdentifier typeId);
}

- (id) init: (UITextField  *) field toolbar:(UIToolbar *) toolbar;
- (void) onPicked:(void (^)(HKQuantityTypeIdentifier)) callback;
- (void) setNewActivity:(NSInteger) index;
@end


@interface TypePickerView () <UIPickerViewDelegate>
@end


@implementation TypePickerView

UITextField *field;
long count;

- (id)init:(UITextField  *) textField toolbar:(UIToolbar *) toolbar {
    self = [super init];
    field = textField;
    
    count = [WRFormat getAllTypeIds].count;
    [self setDelegate:self];
    [field setInputView:self];
    [field setInputAccessoryView:toolbar];
    field.tintColor = [UIColor clearColor];
    return self;
}

- (void) onPicked:(void (^)(HKQuantityTypeIdentifier))callback {
    _callbackHandler = callback;
}

- (void) setNewActivity:(NSInteger) index {
    field.text = [WRFormat typeNameAt:index];
    if(_callbackHandler) {
        _callbackHandler([WRFormat typeIdentifierAt:index]);
    }
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [WRFormat typeNameAt:row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self setNewActivity:row];
}

@end

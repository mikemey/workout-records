#import "TypePickerView.h"
#import "../WRFormat.h"

@interface TypePickerView () <UIPickerViewDelegate>
@end

@implementation TypePickerView {
    UITextField *_field;
    long count;
}

- (id)init:(UITextField  *) field
   toolbar:(UIToolbar *) toolbar
  callback:(void (^)(HKQuantityTypeIdentifier)) callback {
    self = [super init];
    _field = field;
    _callbackHandler = callback;
    
    count = [WRFormat getAllTypeIds].count;
    [self setDelegate:self];
    [_field setInputView:self];
    [_field setInputAccessoryView:toolbar];
    _field.tintColor = [UIColor clearColor];
    return self;
}

- (void) setNewActivity:(NSInteger) index {
    _field.text = [WRFormat typeNameAt:index];
    _callbackHandler([WRFormat typeIdentifierAt:index]);
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

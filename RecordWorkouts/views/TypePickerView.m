#import "TypePickerView.h"

@interface TypePickerView () <UIPickerViewDelegate>
@end


@implementation TypePickerView
UITextField *field;
NSArray *activityNames;
NSArray *activityTypes;

- (id)init:(UITextField  *) textField toolbar:(UIToolbar *) toolbar {
    self = [super init];
    field = textField;
    
    activityNames = [[NSArray alloc] initWithObjects:@"Cycling", @"Swimming", @"Wheelchair", @"Walking/Running", nil];
    activityTypes = [[NSArray alloc] initWithObjects:
             HKQuantityTypeIdentifierDistanceCycling,
             HKQuantityTypeIdentifierDistanceSwimming,
             HKQuantityTypeIdentifierDistanceWheelchair,
             HKQuantityTypeIdentifierDistanceWalkingRunning,
             nil];
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
    field.text = activityNames[index];
    if(_callbackHandler) {
        _callbackHandler(activityTypes[index]);
    }
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return activityNames.count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return activityNames[row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self setNewActivity:row];
}

@end

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

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
static NSArray *activityNames;
static NSArray *activityTypes;

+ (void) initialize {
    activityNames = [[NSArray alloc] initWithObjects:@"Cycling", @"Swimming", @"Wheelchair", @"Walking/Running", @"Calories only", nil];
    activityTypes = [[NSArray alloc] initWithObjects:
                     HKQuantityTypeIdentifierDistanceCycling,
                     HKQuantityTypeIdentifierDistanceSwimming,
                     HKQuantityTypeIdentifierDistanceWheelchair,
                     HKQuantityTypeIdentifierDistanceWalkingRunning,
                     HKQuantityTypeIdentifierActiveEnergyBurned,
                     nil];
}

UITextField *field;


- (id)init:(UITextField  *) textField toolbar:(UIToolbar *) toolbar {
    self = [super init];
    field = textField;
    
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

#import "DurationPickerController.h"
#import "../WRFormat.h"

@implementation DurationPickerController {
    void (^_callbackHandler)(NSTimeInterval date);
    UITextField *_field;
    DurationPickerController *_instance;
    UIDatePicker *_picker;
}

- (id) init: (UITextField *)field
    toolbar: (UIToolbar *) toolbar
   callback: (void (^)(NSTimeInterval)) callback; {
    self = [super init];
    _instance = self;
    _field = field;
    _callbackHandler = callback;
    
    _picker = [[UIDatePicker alloc] init];
    _picker.datePickerMode = UIDatePickerModeCountDownTimer;
    [_picker addTarget:_instance action:@selector(updateNewDuration:) forControlEvents:UIControlEventValueChanged];

    _field.tintColor = [UIColor clearColor];
    [_field setInputAccessoryView:toolbar];
    [_field setInputView:_picker];
    return self;
}

- (void) setInitialDuration: (NSTimeInterval) duration {
    _picker.countDownDuration = duration;
    [self setNewDuration:duration];
}

- (void) updateNewDuration: (UIDatePicker *) sender {
    [self setNewDuration:sender.countDownDuration];
}

- (void) setNewDuration: (NSTimeInterval) duration {
    _field.text = [WRFormat formatDuration:duration];
    _callbackHandler(duration);
}

@end

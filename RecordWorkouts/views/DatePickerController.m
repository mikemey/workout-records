#import "DatePickerController.h"
#import "../WRFormat.h"

@implementation DatePickerController {
    void (^_callbackHandler)(NSDate *date);
    UIDatePicker *picker;
    UITextField *_field;
    DatePickerController *_instance;
}

- (id) init: (UITextField *)field
toolbarBuilder: (ToolbarBuilder *)toolbarBuilder
   callback: (void (^)(NSDate *))callback; {
    self = [super init];
    _instance = self;
    _field = field;
    _callbackHandler = callback;
    
    picker = [[UIDatePicker alloc] init];
    [picker addTarget:_instance action:@selector(updateNewDate:) forControlEvents:UIControlEventValueChanged];
    picker.maximumDate = [NSDate date];
    
    _field.tintColor = [UIColor clearColor];
    [_field setInputAccessoryView:[self createToolbar:toolbarBuilder]];
    [_field setInputView:picker];
    return self;
}

- (UIToolbar*) createToolbar: (ToolbarBuilder *)toolbarBuilder {
    [toolbarBuilder addActionButton:@"Now" target:self action:@selector(setDateNow)];
    [toolbarBuilder addButton:toolbarBuilder.spacer];
    [toolbarBuilder addButton:toolbarBuilder.doneButton];
    return [toolbarBuilder create];
}

 - (void) setDateNow {
     [self setNewDate:[NSDate date]];
 }

- (void) updateNewDate: (UIDatePicker *) sender {
    [self setNewDate:sender.date];
}

- (void) setNewDate: (NSDate *) date {
    _field.text = [WRFormat formatDate:date];
    [picker setDate:date];
    _callbackHandler(date);
}

@end

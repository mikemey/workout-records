#import "ToolbarBuilder.h"

@implementation ToolbarBuilder {
    CGRect _frame;
    NSArray *defaultButtons;
    UIToolbar *defaultToolbar;
    
    NSMutableArray *customButtons;
}

@synthesize doneButton;
@synthesize spacer;

- (id) init: (CGRect)frame target:(id)target doneAction:(SEL)doneAction {
    self = [super init];
    _frame = frame;
    doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain
                                              target:target action:doneAction];
    spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    defaultButtons = [NSArray arrayWithObjects:spacer, doneButton, nil];
    return self;
}

- (UIToolbar *) create {
    return [self createWith:customButtons];
}

- (UIToolbar *) createDefault {
    return [self createWith:defaultButtons];
}

- (UIToolbar *) createWith: (NSArray *)items {
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:_frame];
    [toolBar setTintColor:[UIColor grayColor]];
    [toolBar setItems:items];
    return toolBar;
}

- (void) addActionButton: (NSString *)title target: (id) target action: (SEL) action {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title
       style:UIBarButtonItemStylePlain target:target action:action];
    [self addButton:button];
}

- (void) addButton: (UIBarButtonItem *)button {
    if (customButtons == nil) {
        customButtons = [[NSMutableArray alloc] init];
    }
    [customButtons addObject:button];
}

@end

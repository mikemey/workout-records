#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ToolbarBuilder : NSObject {}

@property UIBarButtonItem *doneButton;
@property UIBarButtonItem *spacer;

- (id) init: (CGRect)frame target:(id)target doneAction:(SEL)doneAction;

- (UIToolbar *) createDefault;
- (UIToolbar *) create;
- (void) addButton: (UIBarButtonItem *)button;
- (void) addActionButton: (NSString *)title target:(id)target action:(SEL)action;

@end

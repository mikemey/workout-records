#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITextField *dateField;
    __weak IBOutlet UITextField *durationField;
    __weak IBOutlet UITextField *distanceField;
    __weak IBOutlet UITextField *caloriesField;
    IBOutlet UITableView *workoutTableView;
}

@end

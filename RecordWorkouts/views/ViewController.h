#import <UIKit/UIKit.h>
@import GoogleMobileAds;

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet GADBannerView *bannerView;
    __weak IBOutlet UITextField *typeField;
    __weak IBOutlet UITextField *dateField;
    __weak IBOutlet UITextField *durationField;
    __weak IBOutlet UITextField *distanceField;
    __weak IBOutlet UITextField *caloriesField;
    IBOutlet UITableView *workoutTableView;
    IBOutlet UILabel *distanceLabel;
}

@end

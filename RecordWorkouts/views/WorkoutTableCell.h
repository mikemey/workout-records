#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>
#import "../WorkoutData.h"
#import "../WRFormat.h"

@interface WorkoutTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (strong, nonatomic) IBOutlet UIImageView *typeImage;
@property (strong, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (strong, nonatomic) IBOutlet UILabel *energyUnitLabel;

- (void) setWorkout:(WorkoutData *)workout;
@end

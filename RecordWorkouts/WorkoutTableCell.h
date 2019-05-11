#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@interface WorkoutTableCell : UITableViewCell

+ (NSString *)formatDate:(NSDate *)date;
+ (NSString *)formatDuration:(NSTimeInterval)duration;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (strong, nonatomic) IBOutlet UIImageView *typeImage;

- (void)setValues:(HKQuantityTypeIdentifier)type
             date:(NSDate *)date
         duration:(NSTimeInterval)duration
         distance:(double)distance
         calories:(int)calories;

@end

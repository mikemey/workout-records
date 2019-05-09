#import <UIKit/UIKit.h>

@interface WorkoutTableCell : UITableViewCell

+ (NSString *)formatDate:(NSDate *)date;
+ (NSString *)formatDuration:(NSTimeInterval)duration;

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *caloriesLabel;

- (void)setValues:(NSDate *)date
         duration:(NSTimeInterval)duration
         distance:(double)distance
         calories:(int)calories;

@end

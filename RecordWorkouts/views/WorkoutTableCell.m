#import "WorkoutTableCell.h"
#import "../WRFormat.h"

@implementation WorkoutTableCell
static UIColor *defaultTextColor;

@synthesize dateLabel;
@synthesize durationLabel;
@synthesize distanceLabel;
@synthesize caloriesLabel;
@synthesize typeImage;
@synthesize distanceUnitLabel;
@synthesize energyUnitLabel;

+ (void) initialize {
    defaultTextColor = [UIColor colorWithRed:210.0f/255.0f
                                green:210.0f/255.0f
                                 blue:210.0f/255.0f
                                alpha:1.0f];
}

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (void) setWorkout:(WorkoutData *)workout {
    [self setTextOn:dateLabel text:[WRFormat formatDate:workout.date] size:16];
    [self setTextOn:durationLabel text:[WRFormat formatDuration:workout.duration] size:12];
    [self setTextOn:distanceLabel text:[WRFormat formatDistance:workout.distance] size:18];
    [self setTextOn:caloriesLabel text:[WRFormat formatCalories:workout.energy] size:18];
    [self setTextOn:distanceUnitLabel text:[WRFormat isMetric] ? @"km" : @"mi" size:11];
    typeImage.image = [UIImage imageNamed:[WRFormat getImageFileFor:workout.type]];
}

- (void)setTextOn:(UILabel *)lbl text:(NSString *)text size:(int)size {
    lbl.font = [UIFont fontWithName:@"Verdana" size:size];
    lbl.textAlignment = NSTextAlignmentRight;
    [lbl setTextColor:defaultTextColor];
    [lbl setText:text];
}

@end

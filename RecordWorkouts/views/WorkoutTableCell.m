#import "WorkoutTableCell.h"

@implementation WorkoutTableCell
static NSDateFormatter *dateTimeFormatter;
static UIColor *textColor;
static NSDictionary *iconFiles;

+ (void) initialize {
    dateTimeFormatter = [[NSDateFormatter alloc] init];
    [dateTimeFormatter setDateFormat:@"eee d LLL hh:mm a"];
    textColor = [UIColor colorWithRed:210.0f/255.0f
                                green:210.0f/255.0f
                                 blue:210.0f/255.0f
                                alpha:1.0f];
    
    id keys[] = { HKQuantityTypeIdentifierActiveEnergyBurned,
        HKQuantityTypeIdentifierDistanceCycling,
        HKQuantityTypeIdentifierDistanceSwimming,
        HKQuantityTypeIdentifierDistanceWheelchair,
        HKQuantityTypeIdentifierDistanceWalkingRunning
    };
    id objects[] = { @"icons-energy.png", @"icons-cycling.png", @"icons-swimming.png", @"icons-wheelchair.png", @"icons-running.png"};
    NSUInteger count = sizeof(objects) / sizeof(id);
    iconFiles = [NSDictionary dictionaryWithObjects:objects forKeys:keys count:count];
}

+ (NSString *)formatDate:(NSDate *)date {
    return [dateTimeFormatter stringFromDate:date];
}

+ (NSString *)formatDuration:(NSTimeInterval)duration {
    NSInteger ti = (NSInteger)duration;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    NSString *hoursString = nil;
    if (hours > 0) {
        hoursString = [NSString stringWithFormat:@"%ld h", hours];
    } else {
        hoursString = @"";
    }
    return [NSString stringWithFormat:@"%@  %2ld min", hoursString, minutes];
}

+ (NSString *)formatDistance:(double)distance {
    return distance >= 100000
    ? [NSString stringWithFormat:@"%.f", distance / 1000]
    : [NSString stringWithFormat:@"%.1f", distance / 1000];
}

+ (NSString *)formatCalories:(int)calories {
    return [NSString stringWithFormat:@"%d", calories];
}

@synthesize dateLabel;
@synthesize durationLabel;
@synthesize distanceLabel;
@synthesize caloriesLabel;
@synthesize typeImage;

- (void)awakeFromNib {
    [super awakeFromNib];
    dateTimeFormatter = [[NSDateFormatter alloc] init];
    [dateTimeFormatter setDateFormat:@"eee d LLL hh:mm a"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setValues:(HKQuantityTypeIdentifier)type
             date:(NSDate *)date
         duration:(NSTimeInterval)duration
         distance:(double)distance
         calories:(int)calories {
    [self setTextOn:dateLabel text:[WorkoutTableCell formatDate:date] size:16];
    [self setTextOn:durationLabel text:[WorkoutTableCell formatDuration:duration] size:12];
    [self setTextOn:distanceLabel text:[WorkoutTableCell formatDistance:distance] size:18];
    [self setTextOn:caloriesLabel text:[WorkoutTableCell formatCalories:calories] size:18];
    typeImage.image = [UIImage imageNamed:iconFiles[type]];
}

- (void)setTextOn:(UILabel *)lbl text:(NSString *)text size:(int)size {
    lbl.font = [UIFont fontWithName:@"Verdana" size:size];
    lbl.textAlignment = NSTextAlignmentRight;
    [lbl setTextColor:textColor];
    [lbl setText:text];
}

@end

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>
#import "../WRFormat.h"

@interface WorkoutTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (strong, nonatomic) IBOutlet UIImageView *typeImage;
@property (strong, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (strong, nonatomic) IBOutlet UILabel *energyUnitLabel;

- (void) setValues:(HKQuantityTypeIdentifier)type
             date:(NSDate *)date
         duration:(NSTimeInterval)duration
         distance:(double)distance
         calories:(int)calories;

- (void) setLabel: (NSString *)text;
@end

@implementation WorkoutTableCell
static UIColor *defaultTextColor;
static UIColor *loadMoreTextColor;

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
    loadMoreTextColor = [UIColor colorWithRed:160.0f/255.0f
                                        green:200.0f/255.0f
                                         blue:160.0f/255.0f
                                        alpha:1.0f];
}

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setValues:(HKQuantityTypeIdentifier)type
              date:(NSDate *)date
          duration:(NSTimeInterval)duration
          distance:(double)distance
          calories:(int)calories {
    [self setTextOn:dateLabel text:[WRFormat formatDate:date] size:16];
    [self setTextOn:durationLabel text:[WRFormat formatDuration:duration] size:12];
    [self setTextOn:distanceLabel text:[WRFormat formatDistance:distance] size:18];
    [self setTextOn:caloriesLabel text:[WRFormat formatCalories:calories] size:18];
    
    if([WRFormat isMetric]) {
        distanceUnitLabel.text = @"km";
    } else {
        distanceUnitLabel.text = @"mi";
    }
    energyUnitLabel.text = @"kcal";
    typeImage.image = [UIImage imageNamed:[WRFormat getImageFileFor:type]];
}


- (void) setLabel: (NSString *)text {
    distanceUnitLabel.text = @"";
    energyUnitLabel.text = @"";
    [self setTextOn:dateLabel text:@"Load more..." size:14 color:loadMoreTextColor align:NSTextAlignmentCenter];
}

- (void)setTextOn:(UILabel *)lbl text:(NSString *)text size:(int)size {
    [self setTextOn:lbl text:text size:size color:defaultTextColor align:NSTextAlignmentRight];
}

 - (void)setTextOn:(UILabel *)lbl
               text:(NSString *)text
               size:(int)size
             color:(UIColor *)color
             align:(NSTextAlignment)align {
    lbl.font = [UIFont fontWithName:@"Verdana" size:size];
    lbl.textAlignment = align;
    [lbl setTextColor:color];
    [lbl setText:text];
}

@end

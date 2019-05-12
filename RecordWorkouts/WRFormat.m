#import "WRFormat.h"

@implementation WRFormat
static NSArray *_typeIds = nil;
static HKQuantityTypeIdentifier _energyTypeId = nil;
static NSArray *_typeNames = nil;
static NSArray *_iconFiles = nil;
static NSDateFormatter *_dateTimeFormatter;
static NSNumber *_isMetric;

+ (HKQuantityTypeIdentifier) getEnergyTypeId {
    if (_energyTypeId == nil) {
        _energyTypeId = HKQuantityTypeIdentifierActiveEnergyBurned;
    }
    return _energyTypeId;
}

+ (NSArray *) getAllTypeIds {
    if (_typeIds == nil) {
        _typeIds = [[NSArray alloc] initWithObjects:
                    HKQuantityTypeIdentifierDistanceCycling,
                    HKQuantityTypeIdentifierDistanceSwimming,
                    HKQuantityTypeIdentifierDistanceWheelchair,
                    HKQuantityTypeIdentifierDistanceWalkingRunning,
                    [self getEnergyTypeId],
                    nil];
    }
    return _typeIds;
}

+ (HKQuantityTypeIdentifier) typeIdentifierAt:(long)index {
    return [[self getAllTypeIds] objectAtIndex:index];
}

+ (NSString *) typeNameFor:(HKQuantityTypeIdentifier)typeId {
    long ix = [[self getAllTypeIds] indexOfObject:typeId];
    return [self typeNameAt:ix];
}

+ (NSString *) typeNameAt:(long)index {
    if (_typeNames == nil) {
        _typeNames = [[NSArray alloc] initWithObjects:
                      @"Cycling",
                      @"Swimming",
                      @"Wheelchair",
                      @"Walking/Running",
                      @"Calories only",
                      nil];
    }
    return [_typeNames objectAtIndex:index];
}

+ (NSString *) getImageFileFor:(HKQuantityTypeIdentifier)typeId {
    if (_iconFiles == nil ) {
        _iconFiles = [[NSArray alloc] initWithObjects:
                      @"icons-cycling.png",
                      @"icons-swimming.png",
                      @"icons-wheelchair.png",
                      @"icons-running.png",
                      @"icons-energy.png",
                      nil];
    }
    long ix = [[self getAllTypeIds] indexOfObject:typeId];
    return [_iconFiles objectAtIndex:ix];
}

+ (NSString *) formatDate:(NSDate *)date {
    if(_dateTimeFormatter == nil) {
        _dateTimeFormatter = [[NSDateFormatter alloc] init];
        [_dateTimeFormatter setDateFormat:@"eee d LLL hh:mm a"];
    }
    return [_dateTimeFormatter stringFromDate:date];
}

+ (NSString *) formatDuration:(NSTimeInterval)duration {
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

+ (float) distanceForWriting: (float) distance {
    if([WRFormat isMetric]) {
        distance = distance * 1000;
    }
    return distance;
}

+ (NSString *) formatDistance:(double)distance {
    if([self isMetric]) {
        distance = distance / 1000;
    }
    return distance >= 100
        ? [NSString stringWithFormat:@"%.f", distance]
        : [NSString stringWithFormat:@"%.1f", distance];
}

+ (NSString *) formatCalories:(int)calories {
    return [NSString stringWithFormat:@"%d", calories];
}

+ (Boolean) isMetric {
    if(_isMetric == nil) {
       _isMetric = [[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem];
    }
    return [_isMetric intValue] == 1;
}

@end

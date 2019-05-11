#import <HealthKit/HKTypeIdentifiers.h>

@interface WRFormat : NSObject

+ (NSArray *) getAllTypeIds;
+ (HKQuantityTypeIdentifier) getEnergyTypeId;
+ (HKQuantityTypeIdentifier) typeIdentifierAt:(long)index;
+ (NSString *) typeNameAt:(long)index;
+ (NSString *) typeNameFor:(HKQuantityTypeIdentifier)typeId;
+ (NSString *) getImageFileFor:(HKQuantityTypeIdentifier)type;

+ (NSString *) formatDate:(NSDate *)date;
+ (NSString *) formatDuration:(NSTimeInterval)duration;
+ (NSString *)formatDistance:(double)distance;
+ (NSString *)formatCalories:(int)calories;

@end

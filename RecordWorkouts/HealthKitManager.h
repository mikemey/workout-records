#import <Foundation/Foundation.h>
#import "WorkoutData.h"

typedef NS_ENUM(NSInteger, HKMQuerySetting) {
    HKMQueryNone,
    HKMQueryResetDate,
    HKMQueryIncreasDate
};

@interface HealthKitManager : NSObject
+ (HealthKitManager *) sharedInstance;

- (void) requestHealthDataPermissions;

- (void) writeWorkout:(HKQuantityTypeIdentifier) activityId
             distance:(float) distance
             calories:(float) calories
            startDate:(NSDate *) startDate
              endDate:(NSDate *) endDate
          finishBlock:(void (^)(NSError *)) finishBlock;

- (void) readWorkouts:(HKMQuerySetting) querySetting
          finishBlock:(void (^)(NSArray *results, NSDate *queryFromDate))finishBlock;

- (void) deleteWorkout:(WorkoutData *)workout finishBlock:(void (^)(NSError *))finishBlock;

@end

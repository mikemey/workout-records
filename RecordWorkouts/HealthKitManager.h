#import <Foundation/Foundation.h>
#import "WorkoutData.h"

@interface HealthKitManager : NSObject
+ (HealthKitManager *) sharedInstance;

- (void) requestHealthDataPermissions;

- (void) writeWorkout:(HKQuantityTypeIdentifier) typeId
             distance:(float) distance
             calories:(float) calories
            startDate:(NSDate *) startDate
              endDate:(NSDate *) endDate
          finishBlock:(void (^)(NSError *)) finishBlock;

- (void) readWorkouts:(void (^)(NSArray *results))finishBlock;
- (void) deleteWorkout:(WorkoutData *)workout finishBlock:(void (^)(NSError *))finishBlock;

@end

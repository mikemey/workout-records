#import <Foundation/Foundation.h>

@interface HealthKitManager : NSObject

// shared instance
+ (HealthKitManager *)sharedInstance;

- (void)requestToWriteDataWithFinishBlock:(void (^)(NSError *error))finishBlock;

/**
 Write Steps
 */
- (void)writeSteps:(NSInteger)steps
         startDate:(NSDate *)startDate
           endDate:(NSDate *)endDate
   withFinishBlock:(void (^)(NSError *error))finishBlock;

/**
 Request to read data
 */
- (void)requestToReadDataWithFinishBlock:(void (^)(NSError *error))finishBlock;

/**
 Read Cycling Distance
 */
- (void)readCyclingDistanceWithFinishBlock:(void (^)(NSError *error, NSNumber *value))finishBlock;

@end

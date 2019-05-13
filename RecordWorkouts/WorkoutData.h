#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface WorkoutData:NSObject {}
@property(nonatomic, readwrite) HKQuantityTypeIdentifier type;
@property(nonatomic, readwrite) NSDate *date;
@property(nonatomic, readwrite) NSTimeInterval duration;
@property(nonatomic, readwrite) double distance;
@property(nonatomic, readwrite) int energy;
@property(nonatomic, readwrite) NSMutableArray *samples;

- (void)addSample:(HKSample *)sample;

@end

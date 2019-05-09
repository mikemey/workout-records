#import <Foundation/Foundation.h>
#import <HealthKit/HKQuantitySample.h>

@interface WorkoutData:NSObject {}
@property(nonatomic, readwrite) NSDate *date;
@property(nonatomic, readwrite) NSTimeInterval duration;
@property(nonatomic, readwrite) double distance;
@property(nonatomic, readwrite) int energy;
@property(nonatomic, readwrite) NSMutableArray *samples;

- (void)addSample:(HKQuantitySample *)sample;

@end

#import "WorkoutData.h"

@implementation WorkoutData
    @synthesize date;
    @synthesize duration;
    @synthesize distance;
    @synthesize energy;
    @synthesize samples;

-(id)init {
    samples = [[NSMutableArray alloc] init];
    return self;
}

- (void)addSample:(HKQuantitySample *)sample {
    [samples addObject:sample];
}

@end

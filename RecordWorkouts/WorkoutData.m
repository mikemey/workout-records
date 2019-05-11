#import "WorkoutData.h"

@implementation WorkoutData
    @synthesize type;
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

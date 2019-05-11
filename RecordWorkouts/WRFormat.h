#import <Foundation/Foundation.h>
#import <HealthKit/HKTypeIdentifiers.h>

@interface WRFormat : NSObject
@property (class, nonatomic, assign, readonly) NSArray *supportedTypeIds;
@property (class, nonatomic, assign, readonly) HKQuantityTypeIdentifier energyTypeId;
@end

@implementation WRFormat
static NSArray *_supportedTypeIds = nil;
static HKQuantityTypeIdentifier _energyTypeId = nil;

+ (HKQuantityTypeIdentifier) energyTypeId {
    if (_energyTypeId == nil) {
        _energyTypeId = HKQuantityTypeIdentifierActiveEnergyBurned;
    }
    return _energyTypeId;
}

+ (NSArray *) supportedTypeIds {
    if (_supportedTypeIds == nil) {
        _supportedTypeIds = [[NSArray alloc] initWithObjects:
                             HKQuantityTypeIdentifierDistanceCycling,
                             HKQuantityTypeIdentifierDistanceSwimming,
                             HKQuantityTypeIdentifierDistanceWheelchair,
                             HKQuantityTypeIdentifierDistanceWalkingRunning,
                             [self energyTypeId],
                             nil];
    }
    return _supportedTypeIds;
}

@end

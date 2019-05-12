#import "HealthKitManager.h"
#import <HealthKit/HealthKit.h>
#import "WRFormat.h"

@interface HealthKitManager ()
@property (nonatomic, retain) HKHealthStore *healthStore;
@property int secondsInWeek;
@end

@implementation HealthKitManager
+ (HealthKitManager *)sharedInstance {
    static HealthKitManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HealthKitManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.healthStore = [[HKHealthStore alloc] init];
        self.secondsInWeek = 60 * 60 * 24 * 7;
    }
    return self;
}

HKObjectType* (^objectTypeFrom)(HKQuantityTypeIdentifier type) =
    ^HKObjectType* (HKQuantityTypeIdentifier type) {
    return [HKObjectType quantityTypeForIdentifier:type];
};

HKSampleType* (^sampleFrom)(HKQuantityTypeIdentifier type) =
    ^HKSampleType*(HKQuantityTypeIdentifier type) {
    return [HKSampleType quantityTypeForIdentifier:type];
};

- (NSArray *) get:(NSArray *) inputIds
        converter:(HKObjectType * (^)(HKQuantityTypeIdentifier))converter {
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:inputIds.count];
    for(HKQuantityTypeIdentifier typeId in inputIds) {
        HKObjectType *type = converter(typeId);
        [types addObject:type];
    }
    return types;
}

- (void)requestHealthDataPermissions {
    NSLog(@"requesting permission");
    NSArray *types = [self get:WRFormat.getAllTypeIds converter:sampleFrom];
    [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:types]
            readTypes:[NSSet setWithArray:types]
            completion:^(BOOL success, NSError * _Nullable error) {
                NSLog(@"success requesting permission: %@", success ? @"YES" : @"NO");
                if (error) {
                    NSLog(@"ERROR requesting permission: %@",error);
                }
            }];
}

- (void) writeWorkout:(HKQuantityTypeIdentifier) activityId
              distance:(float) distance
              calories:(float) calories
             startDate:(NSDate *) startDate
               endDate:(NSDate *) endDate
           finishBlock:(void (^)(NSError *)) finishBlock {
    
    if(!activityId || !startDate || !endDate) {
        NSString *missingParam = @"activity";
        if(!startDate) {
            missingParam = @"start date";
        }
        if(!endDate) {
            missingParam = @"duration";
        }
        NSString *msg = [[NSString alloc] initWithFormat:@"Missing %@", missingParam];
        NSLog(@"ERROR storing: %@", msg);
        id keys[] = { NSLocalizedDescriptionKey };
        id objects[] = { msg };
        NSUInteger count = sizeof(objects) / sizeof(id);
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objects forKeys:keys count:count];
        finishBlock([NSError errorWithDomain:@"WorkoutRecords" code:1 userInfo:userInfo]);
        return;
    }

    NSMutableArray *storeObj = [[NSMutableArray alloc] init];
    if(distance > 0) {
        HKQuantityType *distanceQuantityType = [HKQuantityType quantityTypeForIdentifier:activityId];
        HKQuantity *distanceQuantity = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:distance];
        HKQuantitySample *activity = [HKQuantitySample quantitySampleWithType:distanceQuantityType quantity:distanceQuantity startDate:startDate endDate:endDate];
        [storeObj addObject:activity];
    }
    
    if(calories > 0) {
        HKQuantityType *caloriesQuantityType = [HKQuantityType
            quantityTypeForIdentifier:WRFormat.getEnergyTypeId];
        HKQuantity *caloriesQuantity = [HKQuantity quantityWithUnit:[HKUnit largeCalorieUnit] doubleValue:calories];
        HKQuantitySample *energy = [HKQuantitySample quantitySampleWithType:caloriesQuantityType quantity:caloriesQuantity startDate:startDate endDate:endDate];
        [storeObj addObject:energy];
    }
    
    NSLog(@"STORING: %@, samples: %lu", startDate, storeObj.count);
    [self.healthStore saveObjects:storeObj withCompletion:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success storing: %@", success ? @"YES" : @"NO");
        if (error) {
            NSLog(@"ERROR storing: %@",error);
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            finishBlock(error);
        });
    }];
}

- (void)readWorkouts:(void (^)(NSArray *results))finishBlock {
    NSDate *now = [NSDate date];
    NSDate *startDate = [now dateByAddingTimeInterval:-self.secondsInWeek];
    NSDate *endDate = now;
    
    NSLog(@"fetching data from: %@", startDate);
    [self fetchWorkoutData:startDate endDate:endDate completion:^(NSArray *distances, NSArray *energies) {
        NSMutableArray *workouts = [[NSMutableArray alloc] init];
        NSMutableArray *remainingEnergies = [NSMutableArray arrayWithArray:energies];
        for(HKQuantitySample *distanceSample in distances) {
            WorkoutData *record = [self createBasicWorkoutFrom:distanceSample];
            record.distance = [distanceSample.quantity doubleValueForUnit:[HKUnit meterUnit]];
            
            for(HKQuantitySample *energySample in remainingEnergies) {
                double interval = fabs([energySample.startDate timeIntervalSinceDate:distanceSample.startDate]);
                if(interval < 2) {
                    record.energy = [energySample.quantity doubleValueForUnit:[HKUnit largeCalorieUnit]];
                    [record addSample:energySample];
                    [remainingEnergies removeObjectsInArray:@[energySample]];
                    break;
                }
            }
            [workouts addObject:record];
        }
        for(HKQuantitySample *energySample in remainingEnergies) {
            WorkoutData *record = [self createBasicWorkoutFrom:energySample];
            record.energy = [energySample.quantity doubleValueForUnit:[HKUnit largeCalorieUnit]];
            [workouts addObject:record];
        }
        
        NSArray *sortedResults = [workouts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate *first = [(WorkoutData *)a date];
            NSDate *second = [(WorkoutData *)b date];
            return [second compare:first];
        }];
        finishBlock(sortedResults);
    }];
}

-(WorkoutData*)createBasicWorkoutFrom:(HKQuantitySample *) sample {
    WorkoutData *record = [[WorkoutData alloc] init];
    record.date = sample.startDate;
    record.type = [sample.sampleType identifier];
    record.duration = [sample.endDate timeIntervalSinceDate:sample.startDate];
    [record addSample:sample];
    return record;
}

-(void)fetchWorkoutData:(NSDate *)startDate
                endDate:(NSDate *)endDate
             completion:(void (^)(NSArray* distance, NSArray* energy))completion {
    __block NSMutableArray *distanceResults = [[NSMutableArray alloc] init];
    __block NSArray *energyResult = nil;
    
    NSArray *types = [self get:WRFormat.getAllTypeIds converter:sampleFrom];
    HKObjectType *energyType = objectTypeFrom(WRFormat.getEnergyTypeId);
    NSArray *predicates = [[NSArray alloc] initWithObjects:
                   [HKQuery predicateForObjectsFromSource:[HKSource defaultSource]],
                   [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate],
                   nil];
    NSPredicate *queryPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];

    dispatch_group_t serviceGroup = dispatch_group_create();
    for(HKSampleType *sampleType in types) {
        dispatch_group_enter(serviceGroup);
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: sampleType
               predicate: queryPredicate
                   limit: 0
         sortDescriptors: nil
          resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error) {
              if ([[query objectType] isEqual:energyType]){
                  energyResult = results;
              } else {
                  [distanceResults addObjectsFromArray:results];
              }
              dispatch_group_leave(serviceGroup);
          }];
        [self.healthStore executeQuery:query];
    }
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        completion(distanceResults, energyResult);
    });
}

- (void)deleteWorkout:(WorkoutData *)workout finishBlock:(void (^)(NSError * error))finishBlock {
    NSLog(@"DELETING: %@", workout.date);
    [self.healthStore deleteObjects:workout.samples
                     withCompletion:^(BOOL success, NSError * _Nullable error) {
         NSLog(@"success: %@", success ? @"YES" : @"NO");
         if (error) {
             NSLog(@"ERROR: %@",error);
         }
         dispatch_sync(dispatch_get_main_queue(), ^{
             finishBlock(error);
         });
    }];
}

@end

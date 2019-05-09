#import "HealthKitManager.h"
#import <HealthKit/HealthKit.h>
#import "WorkoutData.h"

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

- (void)requestHealthDataPermissions {
    NSArray *readTypes = @[
       [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
       [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned]
    ];
    
    NSArray *writeTypes = @[
        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned]
    ];
    
    NSLog(@"requesting permission");
    [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:writeTypes]
            readTypes:[NSSet setWithArray:readTypes]
            completion:^(BOOL success, NSError * _Nullable error) {
                NSLog(@"success: %@", success ? @"YES" : @"NO");
                if (error) {
                    NSLog(@"ERROR: %@",error);
                }
            }];
}

- (void)writeCycling:(float) distance
           calories:(float)calories
         startDate:(NSDate *)startDate
           endDate:(NSDate *)endDate
       finishBlock:(void (^)(void))finishBlock {
    NSMutableArray *storeObj = [[NSMutableArray alloc] init];

    if(distance > 0) {
        HKQuantityType *distanceQuantityType = [HKQuantityType
                                                quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
        HKQuantity *distanceQuantity = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:distance];
        HKQuantitySample *cycling = [HKQuantitySample quantitySampleWithType:distanceQuantityType quantity:distanceQuantity startDate:startDate endDate:endDate];
        [storeObj addObject:cycling];
    }
    
    if(calories > 0) {
        HKQuantityType *caloriesQuantityType = [HKQuantityType
                                                quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
        HKQuantity *caloriesQuantity = [HKQuantity quantityWithUnit:[HKUnit largeCalorieUnit] doubleValue:calories];
        HKQuantitySample *energy = [HKQuantitySample quantitySampleWithType:caloriesQuantityType quantity:caloriesQuantity startDate:startDate endDate:endDate];
        [storeObj addObject:energy];
    }
    
    NSLog(@"STORING: %@, samples: %lu", startDate, storeObj.count);
    [self.healthStore saveObjects:storeObj withCompletion:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success: %@", success ? @"YES" : @"NO");
        if (error) {
            NSLog(@"ERROR: %@",error);
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                finishBlock();
            });
        }
    }];
}

- (void)readWorkouts:(void (^)(NSArray *results))finishBlock {
    NSDate *now = [NSDate date];
    NSDate *startDate = [now dateByAddingTimeInterval:-self.secondsInWeek];
    NSDate *endDate = now;
    
    NSLog(@"fetching data from: %@", startDate);
    [self fetchWorkoutData:startDate endDate:endDate completion:^(NSError *error, NSArray *distances, NSArray *energies) {
        if(error) {
            NSLog(@"ERROR: %@",error);
        } else {
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
        }
    }];
}

-(WorkoutData*)createBasicWorkoutFrom:(HKQuantitySample *) sample {
    WorkoutData *record = [[WorkoutData alloc] init];
    record.date = sample.startDate;
    record.duration = [sample.endDate timeIntervalSinceDate:sample.startDate];
    [record addSample:sample];
    return record;
}

-(void)fetchWorkoutData:(NSDate *)startDate
                endDate:(NSDate *)endDate
             completion:(void (^)(NSError* error, NSArray* distance, NSArray* energy))completion {
    __block NSError *distanceError = nil;
    __block NSError *energyError = nil;
    __block NSArray *distanceResult = nil;
    __block NSArray *energyResult = nil;
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate
       endDate:endDate
       options:HKQueryOptionStrictStartDate];
    
    dispatch_group_t serviceGroup = dispatch_group_create();
    dispatch_group_enter(serviceGroup);
    
    HKSampleType *sampleDistance = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    HKSampleQuery *distanceQuery = [[HKSampleQuery alloc] initWithSampleType: sampleDistance
           predicate: predicate
               limit: 0
     sortDescriptors: nil
      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
          if (error) {
              distanceError = error;
          } else {
              distanceResult = results;
          }
          dispatch_group_leave(serviceGroup);
      }];
    [self.healthStore executeQuery:distanceQuery];
    
    dispatch_group_enter(serviceGroup);
    
    HKSampleType *sampleEnergy = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKSampleQuery *energyQuery = [[HKSampleQuery alloc] initWithSampleType: sampleEnergy
           predicate: predicate
               limit: 0
     sortDescriptors: nil
      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
          if (error) {
              energyError = error;
          } else {
              energyResult = results;
          }
          dispatch_group_leave(serviceGroup);
      }];
    [self.healthStore executeQuery:energyQuery];
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        NSError *overallError = nil;
        if (distanceError || energyError) {
            overallError = distanceError ?: energyError;
        }
        completion(overallError, distanceResult, energyResult);
    });
}

- (void)deleteWorkout:(WorkoutData *)workout finishBlock:(void (^)(void))finishBlock {
    NSLog(@"DELETING: %@", workout.date);
    [self.healthStore deleteObjects:workout.samples
                     withCompletion:^(BOOL success, NSError * _Nullable error) {
         NSLog(@"success: %@", success ? @"YES" : @"NO");
         if (error) {
             NSLog(@"ERROR: %@",error);
         } else {
             dispatch_sync(dispatch_get_main_queue(), ^{
                 finishBlock();
             });
         }
    }];
}

@end

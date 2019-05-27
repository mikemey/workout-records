import HealthKit


enum HKMQuerySetting : Int {
    case none
    case resetDate
    case increasDate
}

let METADATA_WR_ID = "WR-ID"
let createNewMetadata: (() -> [String : String]) = { return [METADATA_WR_ID : UUID().uuidString] }
let getWorkoutId: ((_ sample: HKSample) -> String?) = { sample in
    let metadata = sample.metadata!
    return metadata[METADATA_WR_ID] as? String
}

let findSampleById: ((_ samples: [HKSample], _ uuid: String) -> HKSample?) = { samples, uuid in
    return samples.first(where: { sample in uuid == getWorkoutId(sample) })
}

let quantityTypeFrom: ((_ type: HKQuantityTypeIdentifier) -> HKQuantityType) = { type in
    return (HKObjectType.quantityType(forIdentifier: type))!
}

class HealthKitManager {
    static var instance: HealthKitManager = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private let deviceUnit = WRFormat.isMetric ? HKUnit.meter() : HKUnit.mile()
    private let energyUnit = HKUnit.largeCalorie()
    
    private let secondsInWeek = TimeInterval(-60 * 60 * 24 * 7)
    private var queryStartDate = Date()
    
    private let appSourcePredicate = HKQuery.predicateForObjects(from: HKSource.default())
    
    class func sharedInstance() -> HealthKitManager {
        return instance
    }

    func requestHealthDataPermissions() {
        print("requesting permission")
        let allTypes = Set(WRFormat.allSampleTypes)
        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { success, error in
            print("success requesting permission: \(success ? "YES" : "NO")")
            if let error = error {
                print("ERROR requesting permission: \(error)")
            }
        }
    }
    
// ==========================   write workouts    ===========================================
// =========================================================================================
    
    func writeWorkout(_ workout: WorkoutData, finishBlock: @escaping (Error?) -> Void) {
        let metadata = createNewMetadata()
        let endDate = workout.date.addingTimeInterval(workout.duration)

        let distanceQuantity: HKQuantity? = workout.distance.map { distance in
            return HKQuantity(unit: deviceUnit, doubleValue: WRFormat.distanceForWriting(distance))
        }
        let energyQuantity: HKQuantity? = workout.energy.map { energy in
            return HKQuantity(unit: energyUnit, doubleValue: Double(energy))
        }

        var storeObj: [HKSample] = []
        
        switch(workout.activity.type) {
        case let .Quantity(quantityIdentifier):
            if let distanceQuantity = distanceQuantity, quantityIdentifier != WRFormat.energyTypeId {
                let sample = HKQuantitySample(type: quantityTypeFrom(quantityIdentifier), quantity: distanceQuantity,
                                              start: workout.date, end: endDate, metadata: metadata)
                storeObj.append(sample)
            }
            if let energyQuantity = energyQuantity {
                let sample = HKQuantitySample(type: quantityTypeFrom(WRFormat.energyTypeId), quantity: energyQuantity,
                                              start: workout.date, end: endDate, metadata: metadata)
                storeObj.append(sample)
            }
        case let .Workout(workoutType):
            let storeWorkout = HKWorkout(activityType: workoutType,
                                         start: workout.date, end: endDate, duration: workout.duration,
                                         totalEnergyBurned: energyQuantity, totalDistance: distanceQuantity,
                                         metadata: metadata)
            storeObj.append(storeWorkout)
        }

        print(String(format: "STORING: %@, samples: %lu", workout.date as CVarArg, storeObj.count))
        if storeObj.count > 0 {
            healthStore.save(storeObj, withCompletion: { success, error in
                print("success storing: \(success ? "YES" : "NO")")
                if let error = error {
                    print("ERROR storing: \(error)")
                }
                DispatchQueue.main.sync(execute: {
                    finishBlock(error)
                })
            })
        }
    }
    
// ==========================   read workouts     ===========================================
// ==========================================================================================

    func readWorkouts(_ querySetting: HKMQuerySetting?, finishBlock: @escaping (_ results: [WorkoutData], _ queryFromDate: Date) -> Void) {
        let endDate = Date()
        switch querySetting {
        case .resetDate?: queryStartDate = endDate.addingTimeInterval(secondsInWeek)
        case .increasDate?: queryStartDate = queryStartDate.addingTimeInterval(secondsInWeek)
        default: break
        }
        
        print("fetching data from: \(queryStartDate)")
        fetchWorkoutData(queryStartDate, end: endDate) { workouts, distances, energies in
            var workoutData: [WorkoutData] = []
            var remainingEnergies: [HKSample] = energies

            for distanceSample in distances as! [HKQuantitySample] {
                let record = self.createQuantityRecord(from: distanceSample)
                record.distance = distanceSample.quantity.doubleValue(for: self.deviceUnit)

                let wrid = getWorkoutId(distanceSample)
                if let distanceWrid = wrid {
                    let es = findSampleById(energies, distanceWrid) as? HKQuantitySample
                    if let energySample = es {
                        record.energy = Int(energySample.quantity.doubleValue(for: self.energyUnit))
                        record.add(energySample)
                        remainingEnergies = remainingEnergies.filter({ ![energySample].contains($0) })
                    }
                }
                workoutData.append(record)
            }

            for energySample in remainingEnergies as! [HKQuantitySample] {
                let record = self.createQuantityRecord(from: energySample)
                record.energy = Int(energySample.quantity.doubleValue(for: self.energyUnit))
                workoutData.append(record)
            }
            
            for workoutSample in workouts as! [HKWorkout] {
                let record = self.createWorkoutRecord(from: workoutSample)
                workoutData.append(record)
            }
            workoutData.sort(by: { a, b in return a.date > b.date })
            finishBlock(workoutData, self.queryStartDate)
        }
    }
    
    private func createWorkoutRecord(from sample: HKWorkout) -> WorkoutData {
        let activity = WRFormat.findActivity(with: sample.workoutActivityType)
        let record = createBasicRecord(from: sample, activity)
        record.distance = sample.totalDistance.map { distanceSample in
            distanceSample.doubleValue(for: self.deviceUnit)
        }
        record.energy = sample.totalEnergyBurned.map { energySample in
            Int(energySample.doubleValue(for: self.energyUnit))
        }
        return record
    }
    
    private func createQuantityRecord(from sample: HKQuantitySample) -> WorkoutData {
        let activity = WRFormat.findActivity(with: HKQuantityTypeIdentifier.init(rawValue: sample.quantityType.identifier))
        return createBasicRecord(from: sample, activity)
    }
    
    private func createBasicRecord(from sample: HKSample, _ activity: Activity) -> WorkoutData {
        let record = WorkoutData(sample.startDate, sample.endDate, activity)
        record.add(sample)
        return record
    }
    
    private func fetchWorkoutData(_ startDate: Date, end endDate: Date,
                          completion: @escaping (_ workouts: [HKSample], _ distance: [HKSample], _ energy: [HKSample]) -> Void) {
        var workoutResults: [HKSample] = []
        var distanceResults: [HKSample] = []
        var energyResult: [HKSample] = []

        let energyType = quantityTypeFrom(WRFormat.energyTypeId)
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let queryPredicate: NSPredicate? = NSCompoundPredicate(andPredicateWithSubpredicates: [appSourcePredicate, samplePredicate])

        let serviceGroup = DispatchGroup()
        for sampleType in WRFormat.allSampleTypes {
            serviceGroup.enter()
            let resultsHandler: ((_ query: HKSampleQuery, _ results: [HKSample]?, _ error: Error?) -> Void) = {
                query, results, error in
                if let results = results {
                    switch(query.objectType) {
                    case energyType:
                        energyResult = results
                    case WRFormat.workoutType:
                        workoutResults.append(contentsOf: results)
                    default:
                        distanceResults.append(contentsOf: results)
                    }
                }
                serviceGroup.leave()
            }
            let query = HKSampleQuery(sampleType: sampleType, predicate: queryPredicate,
                                  limit: 0, sortDescriptors: nil, resultsHandler: resultsHandler)
            healthStore.execute(query)
        }
        
        serviceGroup.notify(queue: .main) {
            completion(workoutResults, distanceResults, energyResult)
        }
    }

// ==========================   delete workouts     ===========================================
// ==========================================================================================
    
    func deleteWorkout(_ workout: WorkoutData, finishBlock: @escaping (_ error: Error?) -> Void) {
        print("DELETING: \(workout.date)")
        healthStore.delete(workout.samples, withCompletion: { success, error in
            print("success: \(success ? "YES" : "NO")")
            if let error = error {
                print("ERROR: \(error)")
            }
            DispatchQueue.main.sync(execute: {
                finishBlock(error)
            })
        })
    }
}

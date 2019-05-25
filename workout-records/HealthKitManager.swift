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

let objectTypeFrom: ((_ type: HKQuantityTypeIdentifier) -> HKObjectType) = { type in
    return (HKObjectType.quantityType(forIdentifier: type))!
}

let sampleFrom: ((_ type: HKQuantityTypeIdentifier) -> HKSampleType) = { type in
    return (HKSampleType.quantityType(forIdentifier: type))!
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
//        let types = WRFormat.typeIdentifiers.map(sampleFrom)
//        healthStore.requestAuthorization(toShare: Set(types), read: Set(types)) { success, error in
//            print("success requesting permission: \(success ? "YES" : "NO")")
//            if let error = error {
//                print("ERROR requesting permission: \(error)")
//            }
//        }
    }
    
// ==========================   write workouts    ===========================================
// =========================================================================================
    
    func writeWorkout(_ workout: WorkoutData, asWorkout: Bool = false, finishBlock: @escaping (Error?) -> Void) {
//        let metadata = createNewMetadata()
//        let endDate = workout.date.addingTimeInterval(workout.duration)
//
//        let distanceQuantity: HKQuantity? = workout.distance > 0
//            ? HKQuantity(unit: deviceUnit, doubleValue: WRFormat.distanceForWriting(workout.distance))
//            : nil
//        let energyQuantity: HKQuantity? = workout.calories > 0
//            ? HKQuantity(unit: energyUnit, doubleValue: Double(workout.calories))
//            : nil
//
//        var storeObj: [HKSample] = []
//        if asWorkout {
//            let workoutType: HKWorkoutActivityType = HKWorkoutActivityType.cycling
//            let storeWorkout = HKWorkout(activityType: workoutType,
//                                         start: workout.date, end: endDate, duration: workout.duration,
//                                         totalEnergyBurned: energyQuantity, totalDistance: distanceQuantity,
//                                         metadata: metadata)
//            storeObj.append(storeWorkout)
//        } else {
//            if let distanceQuantity = distanceQuantity {
//                let type = HKQuantityType.quantityType(forIdentifier: workout.type.quantityType!)
//                let sample = HKQuantitySample(type: type!, quantity: distanceQuantity,
//                                              start: workout.date, end: endDate, metadata: metadata)
//                storeObj.append(sample)
//            }
//            if let energyQuantity = energyQuantity {
//                let type = HKQuantityType.quantityType(forIdentifier: WRFormat.energyTypeId)
//                let sample = HKQuantitySample(type: type!, quantity: energyQuantity,
//                                              start: workout.date, end: endDate, metadata: metadata)
//                storeObj.append(sample)
//            }
//        }
//
//        print(String(format: "STORING: %@, samples: %lu", workout.date as CVarArg, storeObj.count))
//        if storeObj.count > 0 {
//            healthStore.save(storeObj, withCompletion: { success, error in
//                print("success storing: \(success ? "YES" : "NO")")
//                if let error = error {
//                    print("ERROR storing: \(error)")
//                }
//                DispatchQueue.main.sync(execute: {
//                    finishBlock(error)
//                })
//            })
//        }
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
        fetchWorkoutData(queryStartDate, end: endDate) { distances, energies in
            var workouts: [WorkoutData] = []
            var remainingEnergies: [HKSample] = energies
            
            for distanceSample in distances as! [HKQuantitySample] {
                let record = self.createBasicWorkout(from: distanceSample)
                record.distance = distanceSample.quantity.doubleValue(for: self.deviceUnit)
                
                let wrid = getWorkoutId(distanceSample)
                if let distanceWrid = wrid {
                    let es = findSampleById(energies, distanceWrid) as? HKQuantitySample
                    if let energySample = es {
                        record.calories = Int(energySample.quantity.doubleValue(for: self.energyUnit))
                        record.add(energySample)
                        remainingEnergies = remainingEnergies.filter({ ![energySample].contains($0) })
                    }
                }
                workouts.append(record)
            }
            
            for energySample in remainingEnergies as! [HKQuantitySample] {
                let record = self.createBasicWorkout(from: energySample)
                record.calories = Int(energySample.quantity.doubleValue(for: self.energyUnit))
                workouts.append(record)
            }
            workouts.sort(by: { a, b in return a.date > b.date })
            finishBlock(workouts, self.queryStartDate)
        }
    }
    
    private func createBasicWorkout(from sample: HKQuantitySample) -> WorkoutData {
        let record = WorkoutData(sample.startDate, HKQuantityTypeIdentifier.init(rawValue: sample.quantityType.identifier))
        record.duration = sample.endDate.timeIntervalSince(sample.startDate)
        record.add(sample)
        return record
    }
    
    func fetchWorkoutData(_ startDate: Date, end endDate: Date, completion: @escaping (_ distance: [HKSample], _ energy: [HKSample]) -> Void) {
        var distanceResults: [HKSample] = []
        var energyResult: [HKSample] = []

//        let types = WRFormat.typeIdentifiers.map(sampleFrom)
//        let energyType = objectTypeFrom(WRFormat.energyTypeId)
//        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//        let queryPredicate: NSPredicate? = NSCompoundPredicate(andPredicateWithSubpredicates: [appSourcePredicate, samplePredicate])
//
//        let serviceGroup = DispatchGroup()
//        for sampleType in types {
//            serviceGroup.enter()
//
//            let resultsHandler: ((_ query: HKSampleQuery, _ results: [HKSample]?, _ error: Error?) -> Void) = {
//                query, results, error in
//                if let results = results {
//                    if query.objectType == energyType {
//                        energyResult = results
//                    } else {
//                        distanceResults.append(contentsOf: results)
//                    }
//                }
//                serviceGroup.leave()
//            }
//            let query = HKSampleQuery(sampleType: sampleType, predicate: queryPredicate,
//                                  limit: 0, sortDescriptors: nil, resultsHandler: resultsHandler)
//            healthStore.execute(query)
//        }
        
//        serviceGroup.notify(queue: .main) {
            completion(distanceResults, energyResult)
//        }
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

import HealthKit

class WorkoutData {
    var type: Activity
    var date: Date
    var duration: TimeInterval = 0.0
    var distance: Double = 0.0
    var calories: Int = 0
    var samples: [HKSample] = []
    
    init(_ pDate: Date, _ pType: HKQuantityTypeIdentifier) {
        date = pDate
//        type = WorkoutType(quantityType: pType)
        type = WRFormat.singleActivities[0]
    }
    
    func add(_ sample: HKSample) {
        samples.append(sample)
    }
}

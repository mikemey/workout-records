import HealthKit

class WorkoutData {
    var type: HKQuantityTypeIdentifier
    var date: Date
    var duration: TimeInterval = 0.0
    var distance: Double = 0.0
    var calories: Int = 0
    var samples: [HKSample] = []
    
    init(_ pDate: Date, _ pType: HKQuantityTypeIdentifier) {
        date = pDate
        type = pType
    }
    
    func add(_ sample: HKSample) {
        samples.append(sample)
    }
}

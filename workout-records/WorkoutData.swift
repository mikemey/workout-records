import HealthKit

class WorkoutData {
    var activity: Activity
    var date: Date
    var duration: TimeInterval
    var distance: Double?
    var calories: Int?
    var samples: [HKSample] = []
    
    init(_ date: Date, _ duration: TimeInterval, _ activity: Activity) {
        self.date = date
        self.duration = duration
        self.activity = activity
    }
    
    convenience init(_ startDate: Date, _ endDate: Date, _ activity: Activity) {
        self.init(startDate, endDate.timeIntervalSince(startDate), activity)
    }
    
    func add(_ sample: HKSample) {
        samples.append(sample)
    }
}

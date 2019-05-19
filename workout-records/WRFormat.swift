import HealthKit

class WRFormat {
    static let isMetric = Locale.current.usesMetricSystem
    static let energyTypeId: HKQuantityTypeIdentifier = .activeEnergyBurned
    static let typeIdentifiers = [.distanceCycling, .distanceSwimming, .distanceWheelchair, .distanceWalkingRunning, energyTypeId]
    static let typeNames = ["Cycling", "Swimming", "Wheelchair", "Walking/Running", "Calories only"]
    static let iconFiles = ["icons-cycling.png", "icons-swimming.png", "icons-wheelchair.png", "icons-running.png", "icons-energy.png"]
    static let dateTimeFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "eee d LLL hh:mm a"
        return fmt
    }()
    
    static func typeName(for typeId: HKQuantityTypeIdentifier) -> String {
        return typeNames[typeIdentifiers.firstIndex(of: typeId)!]
    }
    
    static func getImageFile(for typeId: HKQuantityTypeIdentifier) -> String {
        return iconFiles[typeIdentifiers.firstIndex(of: typeId)!]
    }
    
    static func formatDate(_ date: Date) -> String {
        return dateTimeFormatter.string(from: date)
    }
    
    static func formatDuration(_ duration: TimeInterval) -> String {
        let ti = Int(duration)
        let minutes: Int = (ti / 60) % 60
        let hours: Int = ti / 3600
        var hoursString: String = ""
        if hours > 0 {
            hoursString = String(format: "%ld h", hours)
        }
        return String(format: "%@  %2ld min", hoursString, minutes)
    }
    
    static func distanceForWriting(_ distance: Double) -> Double {
        var distance = distance
        if isMetric {
            distance = distance * 1000
        }
        return distance
    }
    
    static func formatDistance(_ distance: Double) -> String {
        var distance = distance
        if isMetric {
            distance = distance / 1000
        }
        return distance >= 100 ? String(format: "%.f", distance) : String(format: "%.1f", distance)
    }
    
    static func formatCalories(_ calories: Int) -> String {
        return "\(calories)"
    }
}

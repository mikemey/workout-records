import HealthKit

enum EitherActivity<A, B> {
    case Quantity(A)
    case Workout(B)
}

struct Activity: Equatable {
    let type: EitherActivity<HKQuantityTypeIdentifier, HKWorkoutActivityType>
    let hrName: String
    let icon: String
    
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        switch (lhs.type, rhs.type) {
        case (let .Quantity(quantityId1), let .Quantity(quantityId2)):
            return quantityId1 == quantityId2
        case (let .Workout(workoutId1), let .Workout(workoutId2)):
            return workoutId1 == workoutId2
        default:
            return false
        }
    }
}

class WRFormat {
    static let isMetric = Locale.current.usesMetricSystem
    static let dateTimeFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "eee d LLL hh:mm a"
        return fmt
    }()

    private static let distanceSampleTypes: [HKSampleType] = {
        return [.distanceCycling, .distanceSwimming, .distanceWheelchair, .distanceWalkingRunning]
            .map { HKSampleType.quantityType(forIdentifier: $0)! }
    }()
    
    static let energyTypeId = HKQuantityTypeIdentifier.activeEnergyBurned
    private static let energySampleType: HKSampleType = HKSampleType.quantityType(forIdentifier: energyTypeId)!
    static let workoutType: HKSampleType = HKObjectType.workoutType()
    static let allSampleTypes = distanceSampleTypes + [energySampleType, workoutType]
    
    static let energyActivity = Activity(type: .Quantity(energyTypeId), hrName: "Energy only", icon: "icons-energy.png")
    static let singleActivitiesLabel = "Record as individual activities"
    private static let distanceActivities: [Activity] = [
        Activity(type: .Quantity(.distanceCycling), hrName: "Cycling (distance + energy)", icon: "icons-cycling.png"),
        Activity(type: .Quantity(.distanceSwimming), hrName: "Swimming (distance + energy)", icon: "icons-swimming.png"),
        Activity(type: .Quantity(.distanceWalkingRunning), hrName: "Walking, Running (distance + energy)", icon: "icons-running.png"),
        Activity(type: .Quantity(.distanceWheelchair), hrName: "Wheelchair (distance + energy)", icon: "icons-wheelchair.png"),
    ]
    static let singleActivities: [Activity] = distanceActivities + [energyActivity]

    static let individualSportsLabel = "Individual Sports"
    static let individualSportsActivities: [Activity] = [
        Activity(type: .Workout(.archery), hrName: "Archery", icon: "icons-archery.png"),
        Activity(type: .Workout(.bowling), hrName: "Bowling", icon: "icons-generic.png"),
        Activity(type: .Workout(.fencing), hrName: "Fencing", icon: "icons-generic.png"),
        Activity(type: .Workout(.gymnastics), hrName: "Performing gymnastics", icon: "icons-gymnastics.png"),
        Activity(type: .Workout(.trackAndField), hrName: "Track + field events", icon: "icons-generic.png")
    ]

    static let teamSportsLabel = "Team Sports"
    static let teamSportsActivities: [Activity] = [
        Activity(type: .Workout(.americanFootball), hrName: "American Football", icon: "icons-generic.png"),
        Activity(type: .Workout(.australianFootball), hrName: "Australian Football", icon: "icons-generic.png"),
        Activity(type: .Workout(.baseball), hrName: "Baseball", icon: "icons-generic.png"),
        Activity(type: .Workout(.basketball), hrName: "Basketball", icon: "icons-generic.png"),
        Activity(type: .Workout(.cricket), hrName: "Cricket", icon: "icons-generic.png"),
        Activity(type: .Workout(.handball), hrName: "Handball", icon: "icons-generic.png"),
        Activity(type: .Workout(.hockey), hrName: "Hockey (Ice / Field Hockey)", icon: "icons-generic.png"),
        Activity(type: .Workout(.lacrosse), hrName: "Lacrosse", icon: "icons-generic.png"),
        Activity(type: .Workout(.rugby), hrName: "Rugby", icon: "icons-generic.png"),
        Activity(type: .Workout(.soccer), hrName: "Football (soccer)", icon: "icons-generic.png"),
        Activity(type: .Workout(.softball), hrName: "Softball", icon: "icons-generic.png"),
        Activity(type: .Workout(.volleyball), hrName: "Volleyball", icon: "icons-generic.png")
    ]

    static let exerciseFitnessLabel = "Exercise and Fitness"
    static let exerciseFitnessActivities: [Activity] = [
        Activity(type: .Workout(.preparationAndRecovery), hrName: "Warm-up, cool down, stretching", icon: "icons-generic.png"),
        Activity(type: .Workout(.flexibility), hrName: "Flexibility workout", icon: "icons-generic.png"),
        Activity(type: .Workout(.running), hrName: "Running, Jogging", icon: "icons-running.png"),
        Activity(type: .Workout(.walking), hrName: "Walking", icon: "icons-generic.png"),
        Activity(type: .Workout(.wheelchairRunPace), hrName: "Wheelchair workout (running pace)", icon: "icons-wheelchair.png"),
        Activity(type: .Workout(.wheelchairWalkPace), hrName: "Wheelchair workout (walking pace)", icon: "icons-wheelchair.png"),
        Activity(type: .Workout(.cycling), hrName: "Cycling", icon: "icons-cycling.png"),
        Activity(type: .Workout(.handCycling), hrName: "Hand cycling", icon: "icons-generic.png"),
        Activity(type: .Workout(.coreTraining), hrName: "Core training", icon: "icons-generic.png"),
        Activity(type: .Workout(.elliptical), hrName: "Elliptical machine", icon: "icons-generic.png"),
        Activity(type: .Workout(.functionalStrengthTraining), hrName: "Strength training (free/body weights)", icon: "icons-generic.png"),
        Activity(type: .Workout(.traditionalStrengthTraining), hrName: "Strength training (using machines)", icon: "icons-generic.png"),
        Activity(type: .Workout(.crossTraining), hrName: "Cross training", icon: "icons-generic.png"),
        Activity(type: .Workout(.mixedCardio), hrName: "Cardio exercise machine", icon: "icons-generic.png"),
        Activity(type: .Workout(.highIntensityIntervalTraining), hrName: "High intensity interval training", icon: "icons-generic.png"),
        Activity(type: .Workout(.jumpRope), hrName: "Jumping rope", icon: "icons-generic.png"),
        Activity(type: .Workout(.stairClimbing), hrName: "Stair climbing machine", icon: "icons-generic.png"),
        Activity(type: .Workout(.stairs), hrName: "Drills using stairs", icon: "icons-generic.png"),
        Activity(type: .Workout(.stepTraining), hrName: "Step bench training", icon: "icons-generic.png")
    ]

    static let studioLabel = "Studio Activities"
    static let studioActivities: [Activity] = [
        Activity(type: .Workout(.barre), hrName: "Barre workout", icon: "icons-generic.png"),
        Activity(type: .Workout(.dance), hrName: "Dancing", icon: "icons-generic.png"),
        Activity(type: .Workout(.mindAndBody), hrName: "Mind + body, meditation", icon: "icons-generic.png"),
        Activity(type: .Workout(.pilates), hrName: "Pilates workout", icon: "icons-generic.png"),
        Activity(type: .Workout(.yoga), hrName: "Practicing yoga", icon: "icons-generic.png")
    ]

    static let racketSportsLabel = "Racket Sports"
    static let racketSportsActivities: [Activity] = [
        Activity(type: .Workout(.badminton), hrName: "Badminton", icon: "icons-generic.png"),
        Activity(type: .Workout(.racquetball), hrName: "Racquetball", icon: "icons-generic.png"),
        Activity(type: .Workout(.squash), hrName: "Squash", icon: "icons-generic.png"),
        Activity(type: .Workout(.tableTennis), hrName: "Table tennis", icon: "icons-generic.png"),
        Activity(type: .Workout(.tennis), hrName: "Tennis", icon: "icons-generic.png")
    ]

    static let outdoorLabel = "Outdoor Activities"
    static let outdoorActivities: [Activity] = [
        Activity(type: .Workout(.climbing), hrName: "Climbing", icon: "icons-generic.png"),
        Activity(type: .Workout(.golf), hrName: "Playing golf", icon: "icons-generic.png"),
        Activity(type: .Workout(.hiking), hrName: "Hiking", icon: "icons-generic.png"),
        Activity(type: .Workout(.play), hrName: "Play-based activities", icon: "icons-generic.png")
    ]

    static let snowIceSportsLabel = "Snow and Ice Sports"
    static let snowIceSportsActivities: [Activity] = [
        Activity(type: .Workout(.crossCountrySkiing), hrName: "Cross country skiing", icon: "icons-generic.png"),
        Activity(type: .Workout(.curling), hrName: "Curling", icon: "icons-generic.png"),
        Activity(type: .Workout(.downhillSkiing), hrName: "Dwnhill skiing", icon: "icons-generic.png"),
        Activity(type: .Workout(.skatingSports), hrName: "Skating activities", icon: "icons-generic.png"),
        Activity(type: .Workout(.snowboarding), hrName: "Snowboarding", icon: "icons-generic.png"),
        Activity(type: .Workout(.snowSports), hrName: "Snow sports, sledding", icon: "icons-generic.png")
    ]

    static let waterLabel = "Water Activities"
    static let waterActivities: [Activity] = [
        Activity(type: .Workout(.swimming), hrName: "Swimming", icon: "icons-swimming.png"),
        Activity(type: .Workout(.paddleSports), hrName: "Canoeing, kayaking, paddling", icon: "icons-generic.png"),
        Activity(type: .Workout(.rowing), hrName: "Rowing", icon: "icons-generic.png"),
        Activity(type: .Workout(.sailing), hrName: "Sailing", icon: "icons-generic.png"),
        Activity(type: .Workout(.surfingSports), hrName: "Surfing, kite/wind surfing", icon: "icons-generic.png"),
        Activity(type: .Workout(.waterFitness), hrName: "Aerobic exercises", icon: "icons-generic.png"),
        Activity(type: .Workout(.waterPolo), hrName: "Playing water polo", icon: "icons-generic.png"),
        Activity(type: .Workout(.waterSports), hrName: "Water sports", icon: "icons-generic.png")
    ]

    static let martialArtsLabel = "Martial Arts"
    static let martialArtsActivities: [Activity] = [
        Activity(type: .Workout(.boxing), hrName: "Boxing", icon: "icons-generic.png"),
        Activity(type: .Workout(.kickboxing), hrName: "Kickboxing", icon: "icons-generic.png"),
        Activity(type: .Workout(.martialArts), hrName: "Practicing martial arts", icon: "icons-generic.png"),
        Activity(type: .Workout(.wrestling), hrName: "Wrestling", icon: "icons-generic.png")
    ]
    
    static let otherLabel = "Others"
    static let otherActivities: [Activity] = [
        Activity(type: .Workout(.other), hrName: "Other", icon: "icons-generic.png")
    ]
    
    private static let allWorkoutActivities: [Activity] =
        individualSportsActivities + teamSportsActivities + exerciseFitnessActivities + studioActivities +
        racketSportsActivities + outdoorActivities + snowIceSportsActivities + waterActivities + martialArtsActivities + otherActivities
    
    static func findActivity(with workoutType: HKWorkoutActivityType) -> Activity {
        return allWorkoutActivities.first(where: { activity in
            switch (activity.type) {
            case let .Workout(type): return workoutType == type
            default: return false
            }
        })!
    }
    
    static func findActivity(with quantityTypeId: HKQuantityTypeIdentifier) -> Activity {
        return singleActivities.first(where: { activity in
            switch (activity.type) {
            case let .Quantity(quantityIdentifier): return quantityIdentifier == quantityTypeId
            default: return false
            }
        })!
    }
    
    static func isDistanceActivity(_ activity: Activity) -> Bool {
        return distanceActivities.contains(activity)
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
    
    static func formatEnergy(_ energy: Int) -> String {
        return "\(energy)"
    }
}

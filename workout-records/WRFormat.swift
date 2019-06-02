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
    
    static let energyActivity = Activity(type: .Quantity(energyTypeId), hrName: "Energy only", icon: "icon-energy.png")
    static let singleActivitiesLabel = "Record individual activities"
    private static let distanceActivities: [Activity] = [
        Activity(type: .Quantity(.distanceCycling), hrName: "Cycling (distance + energy)", icon: "icon-individual-cycling.png"),
        Activity(type: .Quantity(.distanceSwimming), hrName: "Swimming (distance + energy)", icon: "icon-individual-swimming.png"),
        Activity(type: .Quantity(.distanceWalkingRunning), hrName: "Walking, Running (distance + energy)", icon: "icon-individual-running.png"),
        Activity(type: .Quantity(.distanceWheelchair), hrName: "Wheelchair (distance + energy)", icon: "icon-individual-wheelchair.png"),
    ]
    static let singleActivities: [Activity] = distanceActivities + [energyActivity]

    static let individualSportsLabel = "Workouts - Individual Sports"
    static let individualSportsActivities: [Activity] = [
        Activity(type: .Workout(.archery), hrName: "Archery", icon: "icon-archery.png"),
        Activity(type: .Workout(.bowling), hrName: "Bowling", icon: "icon-bowling.png"),
        Activity(type: .Workout(.fencing), hrName: "Fencing", icon: "icon-fencing.png"),
        Activity(type: .Workout(.gymnastics), hrName: "Performing gymnastics", icon: "icon-gymnastics.png"),
        Activity(type: .Workout(.trackAndField), hrName: "Track + field events", icon: "icon-track-field.png")
    ]

    static let teamSportsLabel = "Workouts - Team Sports"
    static let teamSportsActivities: [Activity] = [
        Activity(type: .Workout(.americanFootball), hrName: "American Football", icon: "icon-american-football.png"),
        Activity(type: .Workout(.australianFootball), hrName: "Australian Football", icon: "icon-american-football.png"),
        Activity(type: .Workout(.baseball), hrName: "Baseball", icon: "icon-baseball.png"),
        Activity(type: .Workout(.basketball), hrName: "Basketball", icon: "icon-basketball.png"),
        Activity(type: .Workout(.cricket), hrName: "Cricket", icon: "icon-cricket.png"),
        Activity(type: .Workout(.handball), hrName: "Handball", icon: "icon-handball.png"),
        Activity(type: .Workout(.hockey), hrName: "Hockey (Ice / Field Hockey)", icon: "icon-hockey.png"),
        Activity(type: .Workout(.lacrosse), hrName: "Lacrosse", icon: "icon-lacrosse.png"),
        Activity(type: .Workout(.rugby), hrName: "Rugby", icon: "icon-rugby.png"),
        Activity(type: .Workout(.soccer), hrName: "Football (soccer)", icon: "icon-soccer.png"),
        Activity(type: .Workout(.softball), hrName: "Softball", icon: "icon-softball.png"),
        Activity(type: .Workout(.volleyball), hrName: "Volleyball", icon: "icon-volleyball.png")
    ]

    static let exerciseFitnessLabel = "Workouts - Exercise and Fitness"
    static let exerciseFitnessActivities: [Activity] = [
        Activity(type: .Workout(.preparationAndRecovery), hrName: "Warm-up, cool down, stretching", icon: "icon-warm-up.png"),
        Activity(type: .Workout(.flexibility), hrName: "Flexibility workout", icon: "icon-flexibility.png"),
        Activity(type: .Workout(.running), hrName: "Running, Jogging", icon: "icon-running.png"),
        Activity(type: .Workout(.walking), hrName: "Walking", icon: "icon-walking.png"),
        Activity(type: .Workout(.wheelchairRunPace), hrName: "Wheelchair workout (running pace)", icon: "icon-wheelchair.png"),
        Activity(type: .Workout(.wheelchairWalkPace), hrName: "Wheelchair workout (walking pace)", icon: "icon-wheelchair.png"),
        Activity(type: .Workout(.cycling), hrName: "Cycling", icon: "icon-cycling.png"),
        Activity(type: .Workout(.handCycling), hrName: "Hand cycling", icon: "icon-handcycle.png"),
        Activity(type: .Workout(.coreTraining), hrName: "Core training", icon: "icon-core.png"),
        Activity(type: .Workout(.elliptical), hrName: "Elliptical machine", icon: "icon-spinner.png"),
        Activity(type: .Workout(.functionalStrengthTraining), hrName: "Strength training (free/body weights)", icon: "icon-strength-free.png"),
        Activity(type: .Workout(.traditionalStrengthTraining), hrName: "Strength training (using machines)", icon: "icon-bench-press.png"),
        Activity(type: .Workout(.crossTraining), hrName: "Cross training", icon: "icon-cross.png"),
        Activity(type: .Workout(.mixedCardio), hrName: "Cardio exercise machine", icon: "icon-cardio.png"),
        Activity(type: .Workout(.highIntensityIntervalTraining), hrName: "High intensity interval training", icon: "icon-high-intense.png"),
        Activity(type: .Workout(.jumpRope), hrName: "Jumping rope", icon: "icon-jumping-rope.png"),
        Activity(type: .Workout(.stairClimbing), hrName: "Stair climbing machine", icon: "icon-stepper.png"),
        Activity(type: .Workout(.stairs), hrName: "Drills using stairs", icon: "icon-stair-drill.png"),
        Activity(type: .Workout(.stepTraining), hrName: "Step bench training", icon: "icon-step-bench.png")
    ]

    static let studioLabel = "Workouts - Studio Activities"
    static let studioActivities: [Activity] = [
        Activity(type: .Workout(.barre), hrName: "Barre workout", icon: "icon-generic.png"),
        Activity(type: .Workout(.dance), hrName: "Dancing", icon: "icon-generic.png"),
        Activity(type: .Workout(.mindAndBody), hrName: "Mind + body, meditation", icon: "icon-generic.png"),
        Activity(type: .Workout(.pilates), hrName: "Pilates workout", icon: "icon-generic.png"),
        Activity(type: .Workout(.yoga), hrName: "Practicing yoga", icon: "icon-generic.png")
    ]

    static let racketSportsLabel = "Workouts - Racket Sports"
    static let racketSportsActivities: [Activity] = [
        Activity(type: .Workout(.badminton), hrName: "Badminton", icon: "icon-generic.png"),
        Activity(type: .Workout(.racquetball), hrName: "Racquetball", icon: "icon-generic.png"),
        Activity(type: .Workout(.squash), hrName: "Squash", icon: "icon-generic.png"),
        Activity(type: .Workout(.tableTennis), hrName: "Table tennis", icon: "icon-generic.png"),
        Activity(type: .Workout(.tennis), hrName: "Tennis", icon: "icon-generic.png")
    ]

    static let outdoorLabel = "Workouts - Outdoor Activities"
    static let outdoorActivities: [Activity] = [
        Activity(type: .Workout(.climbing), hrName: "Climbing", icon: "icon-generic.png"),
        Activity(type: .Workout(.golf), hrName: "Playing golf", icon: "icon-generic.png"),
        Activity(type: .Workout(.hiking), hrName: "Hiking", icon: "icon-generic.png"),
        Activity(type: .Workout(.play), hrName: "Play-based activities", icon: "icon-generic.png")
    ]

    static let snowIceSportsLabel = "Workouts - Snow and Ice Sports"
    static let snowIceSportsActivities: [Activity] = [
        Activity(type: .Workout(.crossCountrySkiing), hrName: "Cross country skiing", icon: "icon-generic.png"),
        Activity(type: .Workout(.curling), hrName: "Curling", icon: "icon-generic.png"),
        Activity(type: .Workout(.downhillSkiing), hrName: "Dwnhill skiing", icon: "icon-generic.png"),
        Activity(type: .Workout(.skatingSports), hrName: "Skating activities", icon: "icon-generic.png"),
        Activity(type: .Workout(.snowboarding), hrName: "Snowboarding", icon: "icon-generic.png"),
        Activity(type: .Workout(.snowSports), hrName: "Snow sports, sledding", icon: "icon-generic.png")
    ]

    static let waterLabel = "Workouts - Water Activities"
    static let waterActivities: [Activity] = [
        Activity(type: .Workout(.swimming), hrName: "Swimming", icon: "icon-swimming.png"),
        Activity(type: .Workout(.paddleSports), hrName: "Canoeing, kayaking, paddling", icon: "icon-generic.png"),
        Activity(type: .Workout(.rowing), hrName: "Rowing", icon: "icon-generic.png"),
        Activity(type: .Workout(.sailing), hrName: "Sailing", icon: "icon-generic.png"),
        Activity(type: .Workout(.surfingSports), hrName: "Surfing, kite/wind surfing", icon: "icon-generic.png"),
        Activity(type: .Workout(.waterFitness), hrName: "Aerobic exercises", icon: "icon-generic.png"),
        Activity(type: .Workout(.waterPolo), hrName: "Playing water polo", icon: "icon-generic.png"),
        Activity(type: .Workout(.waterSports), hrName: "Water sports", icon: "icon-generic.png")
    ]

    static let martialArtsLabel = "Workouts - Martial Arts"
    static let martialArtsActivities: [Activity] = [
        Activity(type: .Workout(.boxing), hrName: "Boxing", icon: "icon-generic.png"),
        Activity(type: .Workout(.kickboxing), hrName: "Kickboxing", icon: "icon-generic.png"),
        Activity(type: .Workout(.martialArts), hrName: "Practicing martial arts", icon: "icon-generic.png"),
        Activity(type: .Workout(.wrestling), hrName: "Wrestling", icon: "icon-generic.png")
    ]
    
    static let otherLabel = "Workouts - Others"
    static let otherActivities: [Activity] = [
        Activity(type: .Workout(.other), hrName: "Other", icon: "icon-generic.png")
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

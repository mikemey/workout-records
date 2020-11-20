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
    static let privacyURL = "https://msm-itc.com/workout-records/privacy-policy.html"
    static let documentationURL = "https://msm-itc.com/workout-records/index.html"
    static let activitiesURL = "https://msm-itc.com/workout-records/activities.html"
    static let congratsURL = "https://msm-itc.com/workout-records/api/congrats?v="
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
    
    static let energyActivity = Activity(type: .Quantity(energyTypeId), hrName: "Energy only", icon: "icon-energy")
    static let singleActivitiesLabel = "Record individual activities"
    private static let distanceActivities: [Activity] = [
        Activity(type: .Quantity(.distanceCycling), hrName: "Cycling (distance + energy)", icon: "icon-individual-cycling"),
        Activity(type: .Quantity(.distanceSwimming), hrName: "Swimming (distance + energy)", icon: "icon-individual-swimming"),
        Activity(type: .Quantity(.distanceWalkingRunning), hrName: "Walking, Running (distance + energy)", icon: "icon-individual-running"),
        Activity(type: .Quantity(.distanceWheelchair), hrName: "Wheelchair (distance + energy)", icon: "icon-individual-wheelchair"),
    ]
    static let singleActivities: [Activity] = distanceActivities + [energyActivity]

    static let individualSportsLabel = "Workout - Individual Sports"
    static let individualSportsActivities: [Activity] = [
        Activity(type: .Workout(.archery), hrName: "Archery", icon: "icon-archery"),
        Activity(type: .Workout(.bowling), hrName: "Bowling", icon: "icon-bowling"),
        Activity(type: .Workout(.fencing), hrName: "Fencing", icon: "icon-fencing"),
        Activity(type: .Workout(.gymnastics), hrName: "Performing gymnastics", icon: "icon-gymnastics"),
        Activity(type: .Workout(.trackAndField), hrName: "Track + field events", icon: "icon-track-field")
    ]

    static let teamSportsLabel = "Workout - Team Sports"
    static let teamSportsActivities: [Activity] = [
        Activity(type: .Workout(.americanFootball), hrName: "American Football", icon: "icon-american-football"),
        Activity(type: .Workout(.australianFootball), hrName: "Australian Football", icon: "icon-american-football"),
        Activity(type: .Workout(.baseball), hrName: "Baseball", icon: "icon-baseball"),
        Activity(type: .Workout(.basketball), hrName: "Basketball", icon: "icon-basketball"),
        Activity(type: .Workout(.cricket), hrName: "Cricket", icon: "icon-cricket"),
        Activity(type: .Workout(.handball), hrName: "Handball", icon: "icon-handball"),
        Activity(type: .Workout(.hockey), hrName: "Hockey (Ice / Field Hockey)", icon: "icon-hockey"),
        Activity(type: .Workout(.lacrosse), hrName: "Lacrosse", icon: "icon-lacrosse"),
        Activity(type: .Workout(.rugby), hrName: "Rugby", icon: "icon-rugby"),
        Activity(type: .Workout(.soccer), hrName: "Football (soccer)", icon: "icon-soccer"),
        Activity(type: .Workout(.softball), hrName: "Softball", icon: "icon-softball"),
        Activity(type: .Workout(.volleyball), hrName: "Volleyball", icon: "icon-volleyball")
    ]

    static let exerciseFitnessLabel = "Workout - Exercise and Fitness"
    static let exerciseFitnessActivities: [Activity] = [
        Activity(type: .Workout(.preparationAndRecovery), hrName: "Warm-up, cool down, stretching", icon: "icon-warm-up"),
        Activity(type: .Workout(.flexibility), hrName: "Flexibility", icon: "icon-flexibility"),
        Activity(type: .Workout(.running), hrName: "Running, Jogging", icon: "icon-running"),
        Activity(type: .Workout(.walking), hrName: "Walking", icon: "icon-walking"),
        Activity(type: .Workout(.wheelchairRunPace), hrName: "Wheelchair (running pace)", icon: "icon-wheelchair"),
        Activity(type: .Workout(.wheelchairWalkPace), hrName: "Wheelchair (walking pace)", icon: "icon-wheelchair"),
        Activity(type: .Workout(.cycling), hrName: "Cycling", icon: "icon-cycling"),
        Activity(type: .Workout(.handCycling), hrName: "Hand cycling", icon: "icon-handcycle"),
        Activity(type: .Workout(.coreTraining), hrName: "Core training", icon: "icon-core"),
        Activity(type: .Workout(.elliptical), hrName: "Elliptical machine", icon: "icon-spinner"),
        Activity(type: .Workout(.functionalStrengthTraining), hrName: "Strength training (free/body weights)", icon: "icon-strength-free"),
        Activity(type: .Workout(.traditionalStrengthTraining), hrName: "Strength training (using machines)", icon: "icon-bench-press"),
        Activity(type: .Workout(.crossTraining), hrName: "Cross training", icon: "icon-cross"),
        Activity(type: .Workout(.mixedCardio), hrName: "Cardio exercise machine", icon: "icon-cardio"),
        Activity(type: .Workout(.highIntensityIntervalTraining), hrName: "High intensity interval training", icon: "icon-high-intense"),
        Activity(type: .Workout(.jumpRope), hrName: "Jumping rope", icon: "icon-jumping-rope"),
        Activity(type: .Workout(.stairClimbing), hrName: "Stair climbing machine", icon: "icon-stepper"),
        Activity(type: .Workout(.stairs), hrName: "Drills using stairs", icon: "icon-stair-drill"),
        Activity(type: .Workout(.stepTraining), hrName: "Step bench training", icon: "icon-step-bench")
    ]

    static let studioLabel = "Workout - Studio Activities"
    static let studioActivities: [Activity] = [
        Activity(type: .Workout(.barre), hrName: "Barre", icon: "icon-barre"),
        Activity(type: .Workout(.cardioDance), hrName: "Cardio dancing", icon: "icon-dancing"),
        Activity(type: .Workout(.socialDance), hrName: "Social dancing", icon: "icon-dancing"),
        Activity(type: .Workout(.mindAndBody), hrName: "Mind + body, meditation", icon: "icon-mindful"),
        Activity(type: .Workout(.pilates), hrName: "Pilates", icon: "icon-pilates"),
        Activity(type: .Workout(.yoga), hrName: "Practicing yoga", icon: "icon-yoga")
    ]

    static let racketSportsLabel = "Workout - Racket Sports"
    static let racketSportsActivities: [Activity] = [
        Activity(type: .Workout(.badminton), hrName: "Badminton", icon: "icon-badminton"),
        Activity(type: .Workout(.racquetball), hrName: "Racquetball", icon: "icon-raquet"),
        Activity(type: .Workout(.squash), hrName: "Squash", icon: "icon-squash"),
        Activity(type: .Workout(.tableTennis), hrName: "Table tennis", icon: "icon-table-tennis"),
        Activity(type: .Workout(.tennis), hrName: "Tennis", icon: "icon-tennis")
    ]

    static let outdoorLabel = "Workout - Outdoor Activities"
    static let outdoorActivities: [Activity] = [
        Activity(type: .Workout(.climbing), hrName: "Climbing", icon: "icon-climbing"),
        Activity(type: .Workout(.golf), hrName: "Playing golf", icon: "icon-golf"),
        Activity(type: .Workout(.hiking), hrName: "Hiking", icon: "icon-hiking"),
        Activity(type: .Workout(.play), hrName: "Play-based activities", icon: "icon-play")
    ]

    static let snowIceSportsLabel = "Workout - Snow and Ice Sports"
    static let snowIceSportsActivities: [Activity] = [
        Activity(type: .Workout(.crossCountrySkiing), hrName: "Cross country skiing", icon: "icon-cross-country"),
        Activity(type: .Workout(.curling), hrName: "Curling", icon: "icon-curling"),
        Activity(type: .Workout(.downhillSkiing), hrName: "Downhill skiing", icon: "icon-skiing"),
        Activity(type: .Workout(.skatingSports), hrName: "Skating activities", icon: "icon-ice-skate"),
        Activity(type: .Workout(.snowboarding), hrName: "Snowboarding", icon: "icon-snowboarding"),
        Activity(type: .Workout(.snowSports), hrName: "Snow sports, sledding", icon: "icon-sledge")
    ]

    static let waterLabel = "Workout - Water Activities"
    static let waterActivities: [Activity] = [
        Activity(type: .Workout(.swimming), hrName: "Swimming", icon: "icon-swimming"),
        Activity(type: .Workout(.paddleSports), hrName: "Canoeing, kayaking, paddling", icon: "icon-canoe"),
        Activity(type: .Workout(.rowing), hrName: "Rowing", icon: "icon-rowing"),
        Activity(type: .Workout(.sailing), hrName: "Sailing", icon: "icon-sail"),
        Activity(type: .Workout(.surfingSports), hrName: "Surfing, kite/wind surfing", icon: "icon-surfing"),
        Activity(type: .Workout(.waterFitness), hrName: "Water aerobics", icon: "icon-water-aerobics"),
        Activity(type: .Workout(.waterPolo), hrName: "Playing water polo", icon: "icon-water-polo"),
        Activity(type: .Workout(.waterSports), hrName: "Water skiing, water sports", icon: "icon-waterskiing")
    ]

    static let martialArtsLabel = "Workout - Martial Arts"
    static let martialArtsActivities: [Activity] = [
        Activity(type: .Workout(.boxing), hrName: "Boxing", icon: "icon-boxing"),
        Activity(type: .Workout(.kickboxing), hrName: "Kickboxing", icon: "icon-kickboxing"),
        Activity(type: .Workout(.martialArts), hrName: "Practicing martial arts", icon: "icon-martial-art"),
        Activity(type: .Workout(.wrestling), hrName: "Wrestling", icon: "icon-wrestling")
    ]
    
    static let otherLabel = "Workout - Others"
    static let otherActivities: [Activity] = [
        Activity(type: .Workout(.other), hrName: "Other", icon: "icon-gymnastics")
    ]
    
    private static let allWorkoutActivities: [Activity] =
        individualSportsActivities + teamSportsActivities + exerciseFitnessActivities + studioActivities +
        racketSportsActivities + outdoorActivities + snowIceSportsActivities + waterActivities + martialArtsActivities + otherActivities
    
    static func activitiesIcon(_ activity: Activity) -> String {
        return "\(activity.icon)-black"
    }
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

    static func congratsMessage(handler: @escaping (_ congratsMessage: String?) -> Void) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        if let url = URL(string: congratsURL + version) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("ERROR requesting congrats message: \(error)")
                        handler(nil)
                        return
                    }
                    if let data = data {
                        do {
                            let res = try JSONDecoder().decode(CongratsMessage.self, from: data)
                            handler(res.m)
                        } catch let error {
                            print("ERROR decoding congrats message: \(error)")
                            print("raw message: \(data)")
                            handler(nil)
                        }
                    }
                }
            }.resume()
        } else {
            print("ERROR creating URL: \(congratsURL)")
            handler(nil)
        }
    }
    
    struct CongratsMessage: Codable {
        let m: String
    }
}

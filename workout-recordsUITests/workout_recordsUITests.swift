import XCTest

class workout_recordsUITests: XCTestCase {
    private var mpOpt: MainPageObject?
    private func mainPage() -> MainPageObject { return mpOpt! }

    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        self.mpOpt = MainPageObject(app, self)
    }
    
    private static let dayInterval = 60 * 60 * 24
    private static func pastDate(_ daysPast: Int, _ hour: Int, _ mins: Int) -> Date {
        let date = Date().addingTimeInterval(TimeInterval(-1 * daysPast * dayInterval))
        return Calendar.current.date(bySettingHour: hour, minute: mins, second: 0, of: date)!
    }
    private let swimDate = { return MainPageObject.formatDateTime(pastDate(2, 11, 11)) }()
    private let cycleDate = { return MainPageObject.formatDateTime(pastDate(1, 12, 12)) }()
    private let caloriesDate = { return MainPageObject.formatDateHour(Date()) }()
    
    func testCreateWorkouts() {
        mainPage().deleteAllRecords()
        mainPage().createWorkout(activity: "Swimming", date: (2, 11, (11)), distance: 1.1, calories: 11)
        mainPage().assertWorkout(0, swimDate, "1 h   0 min", "1.1", "11")
        
        mainPage().createWorkout(activity: "Cycling", setNow: true, date: (1, 12, (12)), duration: (0, 22), distance: 2.2)
        mainPage().assertWorkout(0, cycleDate, "  22 min", "2.2", "0")
        
        mainPage().createWorkout(activity: "Calories only", setNow: true, duration: (1, 11), calories: 33)
        mainPage().assertWorkout(0, caloriesDate, "1 h  11 min", "0.0", "33")
        
        XCTAssertEqual(mainPage().workoutCount(), 3)
    }
    
    func testDeleteSecondItem() {
        mainPage().deleteWorkoutRecord(1, ["Cycling", cycleDate, "22 min"])
        XCTAssertEqual(mainPage().workoutCount(), 2)
        XCTAssertEqual(mainPage().getWorkout(0).getCalories(), "33")
        XCTAssertEqual(mainPage().getWorkout(1).getCalories(), "11")
    }
    
    func testXXXLastDeleteAllRecords() {
        XCTAssertEqual(mainPage().workoutCount(), 2)
        mainPage().deleteAllRecords()
        XCTAssertEqual(mainPage().workoutCount(), 0)
    }
}

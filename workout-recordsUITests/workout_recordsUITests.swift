import XCTest

class workout_recordsUITests: XCTestCase {
    var appOpt: XCUIApplication?
    var mainPageOpt: MainPageObject?
    
    override func setUp() {
        continueAfterFailure = false
        appOpt = XCUIApplication()
        appOpt!.launch()
        mainPageOpt = MainPageObject(appOpt!, self)
    }
    
    func app() -> XCUIApplication { return appOpt! }
    func mainPage() -> MainPageObject { return mainPageOpt! }

    override func tearDown() {
        mainPage().deleteAllRecords()
    }

    func testCreateWorkouts() {
        let dayInterval = 60 * 60 * 24
        let twoDaysAgo = Date().addingTimeInterval(TimeInterval(-2 * dayInterval))
        let swimDate = Calendar.current.date(bySettingHour: 11, minute: 11, second: 0, of: twoDaysAgo)!
        let oneDayAgo = Date().addingTimeInterval(TimeInterval(-dayInterval))
        let cycleDate = Calendar.current.date(bySettingHour: 12, minute: 12, second: 0, of: oneDayAgo)!
        
        mainPage().createWorkout(activity: "Swimming", date: (2, 11, (11)), distance: 1.1, calories: 11)
        mainPage().assertWorkout(0, MainPageObject.formatDateTime(swimDate), "1 h   0 min", "1.1", "11")
        
        mainPage().createWorkout(activity: "Cycling", setNow: true, date: (1, 12, (12)), duration: (0, 22), distance: 2.2, calories: 0)
        mainPage().assertWorkout(0, MainPageObject.formatDateTime(cycleDate), "  22 min", "2.2", "0")
        
        mainPage().createWorkout(activity: "Calories only", setNow: true, duration: (1, 11), calories: 33)
        mainPage().assertWorkout(0, MainPageObject.formatDateHour(Date()), "1 h  11 min", "0.0", "33")
        
        XCTAssertEqual(mainPage().workoutCount(), 3)
    }
    
    func testDistanceAllowsOnyOneComma() {
    }
    
    func testDeleteThirdItem() {
//        mainPage().create(activity: "Swimming", distance: 1.1, calories: 11)
//        mainPage().createWorkout(activity: "Cycling", duration: (0, 55), distance: 2.2)
//        mainPage().create(activity: "Calories only", calories: 33)
//       tableViewMemberNameINmainviewcontroller "workoutTableView"
        XCTAssertEqual(mainPage().workoutCount(), 3)
    }
}

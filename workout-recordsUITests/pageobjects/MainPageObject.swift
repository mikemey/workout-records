import XCTest

extension XCUIElement {
    func clear() {
        if !self.isEnabled { return }
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        self.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
    
    func clearAndEnter(_ newText: String) {
        if !self.isEnabled { return }
        self.clear()
        self.typeText(newText)
    }
    
    func oneUp() {
        if !self.isEnabled { return }
        let startCoord = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -35.0))
        endCoord.tap()
        sleep(1)
    }
}

class MainPageObject {
    private let app: XCUIApplication
    private let test: XCTestCase
    
    private let exist = NSPredicate(format: "exists == TRUE")
    private let notExist = NSPredicate(format: "exists == FALSE")
    private let enabled = NSPredicate(format: "enabled == TRUE")
    
    private let deleteWorkoutTitle = "Delete workout?"
    
    init(_ app: XCUIApplication, _ test: XCTestCase) {
        self.app = app
        self.test = test
    }
    
    static func formatDateTime(_ date: Date) -> String {
        return String(WRFormat.formatDate(date).prefix(16))
    }
    
    static func formatDateHour(_ date: Date) -> String {
        return String(WRFormat.formatDate(date).prefix(14))
    }
    
    func assertWorkout(_ index: Int, _ datePrefix: String, _ duration: String,
                       _ distance: String, _ calories: String) {
        let wopo = WorkoutPageObject(getWorkoutCell(index))
        XCTAssertTrue(wopo.getDate().starts(with: datePrefix), "date mismatch (expected prefix / actual date)\n\(datePrefix)\n\(wopo.getDate())")
        XCTAssertEqual(wopo.getDuration(), duration)
        XCTAssertEqual(wopo.getDistance(), distance)
        XCTAssertEqual(wopo.getCalories(), calories)
    }
    
    func getWorkout(_ index: Int) -> WorkoutPageObject {
        return WorkoutPageObject(getWorkoutCell(index))
    }
    
    func createWorkout(activity: String, setNow: Bool = false,
                date: (Int, Int, (Int))? = nil, duration: (Int, Int)? = nil,
                distance: Double? = nil, calories: Int? = nil) {
        
        app.textFields["activity"].tap()
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: activity)
        tapDone()
        
        if setNow {
            app.textFields["date"].tap()
            app.buttons["Now"].tap()
            tapDone()
        }
        if let date = date {
            app.textFields["date"].tap()
            for _ in 1...date.0 {
                app.pickerWheels.element(boundBy: 0).oneUp()
            }
            app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: String(date.1))
            app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: String(date.2))
            tapDone()
        }

        if let duration = duration {
            app.textFields["duration"].tap()
            app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: String(duration.0))
            app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: String(duration.1))
            tapDone()
        }

        let distanceField = app.textFields["distance"]
        if distanceField.isEnabled {
            if let distance = distance {
                distanceField.clearAndEnter(String(distance))
            } else {
                distanceField.clear()
            }
            tapDone()
        }
        
        let caloriesField = app.textFields["calories"]
        if caloriesField.isEnabled {
            if let calories = calories {
                caloriesField.clearAndEnter(String(calories))
            } else {
                caloriesField.clear()
            }
            tapDone()
        }
        
        app.buttons["Record"].tap()
        let recBtnEnabled = test.expectation(for: enabled, evaluatedWith: app.buttons["Record"])
        test.wait(for: [ recBtnEnabled ], timeout: 5)
    }
    
    func workoutCount() -> Int {
        return app.tables.children(matching: .cell).count - 1
    }
    
    func deleteAllRecords() {
        while workoutCount() > 0 {
            deleteWorkoutRecord(0)
        }
    }
    
    func hasWorkoutRecord() -> Bool {
        return getWorkoutCell(0).exists
    }
    
    func deleteWorkoutRecord(_ index: Int) {
        let cell = getWorkoutCell(index)
        cell.swipeLeft()
        cell.buttons["Delete"].tap()
        waitFor(alertTitle: deleteWorkoutTitle, to: exist)
        getAlert(deleteWorkoutTitle).buttons["Delete"].tap()
        waitFor(alertTitle: deleteWorkoutTitle, to: notExist)
    }
    
    private func getWorkoutCell(_ index: Int) -> XCUIElement {
        return app.cells.element(matching: .cell, identifier: "WorkoutTableCell_\(index)")
    }
    
    private func tapDone() { app.buttons["Done"].tap() }
    private func getAlert(_ title: String) -> XCUIElement { return app.alerts[title] }
    
    private func waitFor(alertTitle title: String, to predicate: NSPredicate) {
        let alert = test.expectation(for: predicate, evaluatedWith: getAlert(title))
        test.wait(for: [ alert ], timeout: 5)
    }
}

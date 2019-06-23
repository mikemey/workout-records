import XCTest

class mainView_inputTests: XCTestCase {
    private var mpOpt: MainPageObject?
    private func mainPage() -> MainPageObject { return mpOpt! }
    
    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        self.mpOpt = MainPageObject(app, self)
    }
    
    func testInputFields() {
        checkRecordButton_initialState()
        allowOnlyOneComma_in_distanceField()
        allowOnlyUpToMaximum_in_energyField()
        checkDurationField()
        checkFields_when_singleDistanceActivity()
        checkFields_when_energyOnlyActivity()
        checkFields_when_workoutActivity()
    }
    
    private func checkRecordButton_initialState() {
        XCTAssertFalse(mainPage().getRecordButton().isEnabled)
    }
    
    private func allowOnlyOneComma_in_distanceField() {
        mainPage().sendToDistanceField(["1", ".", "1", "."])
        XCTAssertEqual(mainPage().getDistanceValue(), "1.1")
    }
    
    private func allowOnlyUpToMaximum_in_energyField() {
        mainPage().sendToEnergyField(["1", "0", "1", "0", "0"])
        XCTAssertEqual(mainPage().getEnergyValue(), "1010")
    }
    
    private func checkDurationField() {
        let expectedDefaultDuration = "1 h   0 min"
        XCTAssertEqual(mainPage().getDurationValue(), expectedDefaultDuration)
        mainPage().getDurationField().tap()
        mainPage().setDurationHours(0)
        XCTAssertEqual(mainPage().getDurationValue(), "   0 min")
        mainPage().setDurationHours(2)
        mainPage().setDurationMinutes(55)
        mainPage().tapDone()
        XCTAssertEqual(mainPage().getDurationValue(), "2 h  55 min")
    }
    
    private func checkFields_when_singleDistanceActivity() {
        mainPage().selectActivity("Walking, Running (distance + energy)")
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
        mainPage().clearDistanceField()
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
        mainPage().getDistanceField().clearAndEnter("5")
        mainPage().clearEnergyField()
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
        mainPage().clearDistanceField()
        XCTAssertFalse(mainPage().getRecordButton().isEnabled)
        mainPage().getDistanceField().clearAndEnter("5")
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
    }
    
    private func checkFields_when_energyOnlyActivity() {
        mainPage().selectActivity("Energy only")
        XCTAssertFalse(mainPage().getRecordButton().isEnabled)
        XCTAssertFalse(mainPage().getDistanceField().isEnabled)
        mainPage().getEnergyField().clearAndEnter("5")
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
    }
    
    private func checkFields_when_workoutActivity() {
        mainPage().selectActivity("Strength training (free/body weights)")
        mainPage().clearDistanceField()
        mainPage().clearEnergyField()
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
        XCTAssertTrue(mainPage().getDistanceField().isEnabled)
    }
}

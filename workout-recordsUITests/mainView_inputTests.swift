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
        checkFields_when_singleDistanceActivity()
        checkFields_when_energyOnlyActivity()
        checkFields_when_workoutActivity()
    }
    
    func checkRecordButton_initialState() {
        XCTAssertFalse(mainPage().getRecordButton().isEnabled)
    }
    
    func allowOnlyOneComma_in_distanceField() {
        mainPage().sendToDistanceField(["1", ".", "1", "."])
        XCTAssertEqual(mainPage().getDistanceValue(), "1.1")
    }
    
    func allowOnlyUpToMaximum_in_energyField() {
        mainPage().sendToEnergyField(["1", "0", "1", "0", "0"])
        XCTAssertEqual(mainPage().getEnergyValue(), "1010")
    }
    
    func checkFields_when_singleDistanceActivity() {
        mainPage().selectActivity("Walking, Running (distance + energy)")
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
        mainPage().clearDistanceField()
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
        mainPage().sendToDistanceField(["5"])
        mainPage().clearEnergyField()
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
        mainPage().clearDistanceField()
        XCTAssertFalse(mainPage().getRecordButton().isEnabled)
        mainPage().sendToDistanceField(["5"])
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
    }
    
    func checkFields_when_energyOnlyActivity() {
        mainPage().selectActivity("Energy only")
        XCTAssertFalse(mainPage().getRecordButton().isEnabled)
        XCTAssertFalse(mainPage().getDistanceField().isEnabled)
        mainPage().sendToEnergyField(["5"])
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
    }
    
    func checkFields_when_workoutActivity() {
        mainPage().clearEnergyField()
        mainPage().selectActivity("Strength training (free/body weights)")
        XCTAssertTrue(mainPage().getRecordButton().isEnabled)
        XCTAssertTrue(mainPage().getDistanceField().isEnabled)
    }
}

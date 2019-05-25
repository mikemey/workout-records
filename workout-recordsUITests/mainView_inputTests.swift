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
        allowOnlyOneComma_In_DistanceField()
        allowOnlyUpToMaximum_in_CaloriesField()
    }
    
    func allowOnlyOneComma_In_DistanceField() {
        mainPage().sendToDistanceField(["1", ".", "1", "."])
        XCTAssertEqual(mainPage().getDistanceValue(), "1.1")
    }
    
    func allowOnlyUpToMaximum_in_CaloriesField() {
        mainPage().sendToCaloriesField(["1", "0", "1", "0", "0"])
        XCTAssertEqual(mainPage().getCaloriesValue(), "1010")
    }
}

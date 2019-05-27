import XCTest

class WorkoutPageObject {
    let cell: XCUIElement
    
    init(_ cell: XCUIElement) {
        self.cell = cell
    }
    
    func getDate() -> String {
        return getLabel("date")
    }
    
    func getDuration() -> String {
        return getLabel("duration")
    }
    
    func getDistance() -> String {
        return getLabel("distance")
    }
    
    func getEnergy() -> String {
        return getLabel("energy")
    }
    
    private func getLabel(_ identifier: String) -> String {
        return cell.staticTexts[identifier].label
    }
}

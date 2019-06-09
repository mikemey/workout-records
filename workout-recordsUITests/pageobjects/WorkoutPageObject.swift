import XCTest

class WorkoutPageObject {
    let cell: XCUIElement
    
    init(_ cell: XCUIElement) {
        self.cell = cell
    }
    
    func getDate() -> String {
        return getLabelOf("date")
    }
    
    func getDuration() -> String {
        return getLabelOf("duration")
    }
    
    func getDistance() -> String {
        return getLabelOf("distance")
    }
    
    func distanceExists() -> Bool {
        return getTextElement("distance").exists
    }
    
    func getEnergy() -> String {
        return getLabelOf("energy")
    }
    
    func energyExists() -> Bool {
        return getTextElement("energy").exists
    }
    
    private func getLabelOf(_ identifier: String) -> String {
        return getTextElement(identifier).label
    }
    
    private func getTextElement(_ identifier: String) -> XCUIElement {
        return cell.staticTexts[identifier]
    }
}

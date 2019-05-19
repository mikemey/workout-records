//
//  workout_recordsUITests.swift
//  workout-recordsUITests
//
//  Created by Michael on 18/05/2019.
//  Copyright © 2019 mmi. All rights reserved.
//

import XCTest

class workout_recordsUITests: XCTestCase {
    var app: XCUIApplication?
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app!.launch()
    }

    override func tearDown() {
        
    }

    func testExample2() {
        let a = app!
//        a.textFields["distance"].tap()
//        a/*@START_MENU_TOKEN@*/.keys["1"]/*[[".keyboards.keys[\"1\"]",".keys[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        a.keys["2"].tap()
//        a/*@START_MENU_TOKEN@*/.keys["."]/*[[".keyboards.keys[\".\"]",".keys[\".\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        a/*@START_MENU_TOKEN@*/.keys["3"]/*[[".keyboards.keys[\"3\"]",".keys[\"3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//
//        a.textFields["calories"].tap()
//        a/*@START_MENU_TOKEN@*/.keys["4"]/*[[".keyboards.keys[\"4\"]",".keys[\"4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        a/*@START_MENU_TOKEN@*/.keys["5"]/*[[".keyboards.keys[\"5\"]",".keys[\"5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        a.buttons["Record"].tap()
        
//        let cell = a.tables["workoutTableCell"].cells.element(boundBy: 0)
//        let children = a.tables["workoutTableCell"].children(matching: .textField)
//        let workoutTable = a.tables["workoutTableCell"]
//        let cell = workoutTable.cells.element(boundBy: 0)
        let tableCell = a.tables.children(matching: .cell).element(boundBy: 2)
        print("=============  TABLE CELL ============================")
        print(tableCell)
        print("=============  Labels ============================")
        let whatever = tableCell.children(matching: .any).count
        print(tableCell.staticTexts["distance"].label)
        print("=============  Labels ============================")
//        print(cell.children(matching: .any).count)
//        print("=============  Label? ============================")
//        print("=============  cell.textFields ============================")
//        print(cell.children(matching: .textField))
//        XCTAssertTrue(cell.textFields["distance"].label == "12.3")
//        XCTAssertTrue(cell.textFields["calories"].label == "46")
    }
    
    func testSelectPicker() {
        let a = app!
        a.textFields["activity"].tap()
        a/*@START_MENU_TOKEN@*/.pickerWheels["Cycling"]/*[[".pickers.pickerWheels[\"Cycling\"]",".pickerWheels[\"Cycling\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.adjust(toPickerWheelValue: "Wheelchair")
        a.textFields["distance"].tap()
        
        let key = a/*@START_MENU_TOKEN@*/.keys["2"]/*[[".keyboards.keys[\"2\"]",".keys[\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key.tap()
        
        let key2 = a/*@START_MENU_TOKEN@*/.keys["5"]/*[[".keyboards.keys[\"5\"]",".keys[\"5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key2.tap()
        a.textFields["calories"].tap()
        let key3 = a/*@START_MENU_TOKEN@*/.keys["3"]/*[[".keyboards.keys[\"3\"]",".keys[\"3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key3.tap()
        a.buttons["Record"].tap()
        
    }

    func testDeleteItem() {
        let a = app!
        let entriesQuery = a.tables.children(matching: .cell)
        print("====> BEFORE:", entriesQuery.count)
        let cell = entriesQuery.element(boundBy: 0)
        cell.swipeLeft()
        entriesQuery.buttons["Delete"].tap()
        a.alerts["Delete workout?"].buttons["Delete"].tap()
        
        let removed = NSPredicate(format: "exists == 0")
        
        let alertRemoved = expectation(for: removed, evaluatedWith: a.alerts["Delete workout?"], handler: nil)
        wait(for: [ alertRemoved], timeout: 10.0)
        let cellRemoved = expectation(for: removed, evaluatedWith: cell, handler: nil)
        wait(for: [cellRemoved], timeout: 10.0)
        
        print("====>  AFTER:", a.tables.children(matching: .cell).count)
    }
}

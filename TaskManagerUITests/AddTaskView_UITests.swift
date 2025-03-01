//
//  AddTaskView_UITests.swift
//  TaskManagerUITests
//
//  Created by Janaina A on 01/03/2025.
//

import XCTest

final class AddTaskView_UITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_AddTaskView_UITests_AddTaskButton_CreateTask() {
        let addButton = app/*@START_MENU_TOKEN@*/.buttons["AddTaskButton"]/*[[".buttons[\"Add\"]",".buttons[\"AddTaskButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.exists)
        titleField.tap()
        titleField.typeText("Test Task") //Use "" to check text validation test
        
        let descriptionField = app.textViews.element(boundBy: 0)
        XCTAssertTrue(descriptionField.exists)
        descriptionField.tap()
        descriptionField.typeText("Test description")
        
        app.buttons["calendarButton"].tap()
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        doneButton.tap()
        
        let saveButton = app.buttons["SaveTaskButton"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        
        if app.staticTexts["Please enter the Title"].exists {
            XCTFail("Toast alert appeared")
        }
        XCTAssertFalse(app.alerts.element.exists)
    }
    
}

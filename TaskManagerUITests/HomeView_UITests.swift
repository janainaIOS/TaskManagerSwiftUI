//
//  HomeView_UITests.swift
//  TaskManagerUITests
//
//  Created by Janaina A on 01/03/2025.
//

import XCTest

final class HomeView_UITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_HomeView_UITests_FilterTasks() {
        let filterButton = app.buttons["FilterButton"]
        XCTAssertTrue(filterButton.exists)
        filterButton.tap()
        
        sleep(3)
        let completedButton = app.buttons["Completed"]
        XCTAssertTrue(completedButton.exists)
        completedButton.tap()
        
        sleep(3)
        let filteredTask = app.staticTexts["Test Task"]
        XCTAssertTrue(filteredTask.exists)
    }
    
    func test_HomeView_UITests_AddTaskButtonAnimation() throws {
        let addTaskButton = app.buttons["AddTaskButton"]
        XCTAssertTrue(addTaskButton.exists, "Add Task button should exist")
        
        XCTAssertEqual(addTaskButton.value as? String, "Normal", "Initial button state should be Normal")
        
        addTaskButton.tap()
        
        sleep(UInt32(0.3))
        XCTAssertEqual(addTaskButton.value as? String, "Animating", "Button should scale due to animation")
        
        sleep(1)
        XCTAssertEqual(addTaskButton.value as? String, "Normal", "Button animation ended")
    }
}

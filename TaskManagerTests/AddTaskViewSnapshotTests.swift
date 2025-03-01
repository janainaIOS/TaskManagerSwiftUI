//
//  AddTaskViewSnapshotTests.swift
//  TaskManagerTests
//
//  Created by Janaina A on 01/03/2025.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import TaskManager 

final class AddTaskViewSnapshotTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMyViewLightMode() {
        let view = AddTaskView(task: Task(title: "", descriptn: "", date: "", priority: "low"))
        let host = UIHostingController(rootView: view)
        host.overrideUserInterfaceStyle = .light
        
        assertSnapshot(of: host, as: .image, named: "LightMode")
    }

    func testMyViewDarkMode() {
        let view = AddTaskView(task: Task(title: "", descriptn: "", date: "", priority: "low"))
        let host = UIHostingController(rootView: view)
        host.overrideUserInterfaceStyle = .dark
        
        assertSnapshot(of: host, as: .image, named: "DarkMode")
    }
}

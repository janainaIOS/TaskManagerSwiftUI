//
//  TaskModel.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import Foundation

struct Task: Codable {
    var id: String = UUID().uuidString
    var title: String
    var descriptn: String
    var date: String
    var priority: String
    var completed: Bool = false
}

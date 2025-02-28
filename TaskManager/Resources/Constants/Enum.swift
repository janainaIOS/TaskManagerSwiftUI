//
//  Enum.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import Foundation
import SwiftUI

/// MARK: - Date and Time
enum dateFormat: String {
    case ddMMMyyyy            = "dd MMM yyyy" // 07 Feb 2025
}

enum TaskPriority: String, CaseIterable {
    case low
    case medium
    case high
    
    var color : Color {
        switch self {
        case .low:
            return .green1
        case .medium:
            return .orange1
        case .high:
            return .red1
        }
    }
}

enum ThemeColor: String, CaseIterable {
    case aqua
    case green
    case plum
    case lemon
    case Iron
    case grape
    
    var color : Color {
        switch self {
        case .aqua:
            return .aqua
        case .green:
            return .green2
        case .plum:
            return .plum
        case .lemon:
            return .lemon
        case .Iron:
            return .iron
        case .grape:
            return .grape
        }
    }
}

enum FilterOptions: String, CaseIterable {
    case all       = "All"
    case completed = "Completed"
    case pending   = "Pending"
    case title    = "Title"
    case dueDate  = "Due Date"
    case priority = "Priority"
}

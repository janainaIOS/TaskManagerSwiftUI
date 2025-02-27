//
//  Enum.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import Foundation
import SwiftUI

// MARK: - Date and Time
enum dateFormat: String {
    case yyyyMMddHHmmss       = "yyyy-MM-dd HH:mm:ss" // 2023-04-30 16:00:00
    case ddMMMyyyy            = "dd MMM yyyy" // 07-February-2025
    case ddMMyyyy             = "dd/MM/yyyy" // 12/08/2023
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
    case green1
    case plum
    case lemon
    case Iron
    case grape
    
    var color : Color {
        switch self {
        case .aqua:
            return .aqua
        case .green1:
            return .green1
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

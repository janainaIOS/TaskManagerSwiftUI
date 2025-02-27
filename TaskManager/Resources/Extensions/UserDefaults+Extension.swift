//
//  UserDefaults+Extension.swift
//  TaskManager
//
//  Created by Janaina A on 27/02/2025.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let appThemeColor = "appThemeColor"
    }
    
    var appThemeColor: String {
        get { string(forKey: Keys.appThemeColor) ?? ThemeColor.grape.rawValue }
        set { set(newValue, forKey: Keys.appThemeColor) }
    }
    
}

//
//  ColorManager.swift
//  TaskManager
//
//  Created by Janaina A on 28/02/2025.
//

import SwiftUI

class ColorManager {
    @AppStorage("appThemeColor") static var appThemeColor: String = ThemeColor.grape.rawValue
    
    static var currentColor: Color {
        ThemeColor(rawValue: appThemeColor)?.color ?? .grape
    }
}

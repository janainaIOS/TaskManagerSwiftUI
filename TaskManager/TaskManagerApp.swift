//
//  TaskManagerApp.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import SwiftUI

@main
struct TaskManagerApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("appThemeColor") private var appThemeColor: String = ThemeColor.grape.rawValue
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            // Set app theme color
            .accentColor(ThemeColor(rawValue: appThemeColor)?.color ?? .grape)
            .tint(ThemeColor(rawValue: appThemeColor)?.color ?? .grape)
        }
    }
}

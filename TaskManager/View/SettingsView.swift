//
//  SettingsView.swift
//  TaskManager
//
//  Created by Janaina A on 27/02/2025.
//

import SwiftUI

struct SideMenu: View {
    @Binding var isShowing: Bool
    var content: AnyView
    var edgeTransition: AnyTransition = .move(edge: .leading)
    var body: some View {
        ZStack(alignment: .top) {
            if (isShowing) {
                Color(uiColor: UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white
                })
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing.toggle()
                }
                content
                    .transition(edgeTransition)
                    .background(
                        Color.clear
                    )
            }
        }
        .frame(maxWidth: 250, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
    }
}

struct SettingsView: View {
    
    @AppStorage("appThemeColor") private var appThemeColor: String = ThemeColor.grape.rawValue
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Settings")
                .font(.title)
                .foregroundColor(.primary)
                .padding(.top, 50)
                .frame(width: 250)
            
            Text("Theme Color")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 50)
            VStack(spacing: 15) {
                ForEach(ThemeColor.allCases, id: \.self) { theme in
                    Circle()
                        .fill(theme.color)
                        .frame(width: 25, height: 25)
                        .overlay(
                            Circle()
                                .strokeBorder(appThemeColor == theme.rawValue ? .primary : Color.clear, lineWidth: 3)
                        )
                        .contentShape(Circle())
                        .onTapGesture {
                            appThemeColor = theme.rawValue
                            ColorManager.appThemeColor = theme.rawValue
                        }
                }
            }
            .padding()
        }
        .background(Color(uiColor: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white
        }))
        .frame(maxWidth: 250, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    SettingsView()
}

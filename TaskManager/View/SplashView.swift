//
//  SplashView.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        NavigationStack {
            if isActive {
                HomeView()
            } else {
                VStack {
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    Text("Task Manager")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}

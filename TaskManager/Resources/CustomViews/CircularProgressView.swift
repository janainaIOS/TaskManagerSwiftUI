//
//  CircularProgressView.swift
//  TaskManager
//
//  Created by Janaina A on 27/02/2025.
//

import SwiftUI

struct CircularProgressView: View {
    var targetProgress: Double
    var lineWidth: CGFloat = 9
    var color: Color = .blue
    
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background Circle (Track)
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
            
            // Progress Circle (Arc Length Animation)
            Circle()
                .trim(from: 0.0, to: animatedProgress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90)) // Start from top
                .animation(.easeInOut(duration: 3.0), value: animatedProgress) // Smooth animation
            
            // Percentage Text
            Text("\(Int(animatedProgress * 100))%")
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
        }
        .frame(width: 80, height: 80)
        .onAppear {
            animateProgress()
        }
        .onChange(of: targetProgress) {
            animateProgress()
        }
    }
    
    private func animateProgress() {
        withAnimation {
            animatedProgress = targetProgress
        }
    }
}


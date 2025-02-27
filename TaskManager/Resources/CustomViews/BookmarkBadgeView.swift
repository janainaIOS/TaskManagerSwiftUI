//
//  BookmarkBadgeView.swift
//  TaskManager
//
//  Created by Janaina A on 27/02/2025.
//

import SwiftUI

struct BookmarkBadge: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let cutWidth: CGFloat = width / 3 // Adjust for bookmark cut depth
        
        path.move(to: CGPoint(x: 0, y: 0)) // Top-left
        path.addLine(to: CGPoint(x: width, y: 0)) // Top-right
        path.addLine(to: CGPoint(x: width, y: height - cutWidth)) // Right before cut
        path.addLine(to: CGPoint(x: width / 2, y: height)) // Bottom center point
        path.addLine(to: CGPoint(x: 0, y: height - cutWidth)) // Left before cut
        path.addLine(to: CGPoint(x: 0, y: 0)) // Back to top-left
        path.closeSubpath()
        
        return path
    }
}

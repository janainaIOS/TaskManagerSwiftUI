//
//  HomeView.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import SwiftUI

struct HomeView: View {
    
    @State private var addTaskTapped = false
    
    var body: some View {
        
            NavigationLink(destination : ContentView()) {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
               
                }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    addTaskTapped.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.accent)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 0)
                    
                }
                .padding()
                
            }
          .fullScreenCover(isPresented: $addTaskTapped) {
           // .sheet(isPresented: self.$addTaskTapped) {
              AddTaskView(isForEdit: false, task: Task(title: "", descriptn: "", date: "", priority: "low"))
            }
            
        }
    
}

#Preview {
    HomeView()
}

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

struct BookmarkBadgeTileView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Tile
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue.opacity(0.2))
                .frame(width: 200, height: 120)
                .shadow(radius: 3)
                .overlay(
                    Text("Tile Content")
                        .font(.headline)
                        .foregroundColor(.black)
                )
            
            // Bookmark Badge
            ZStack {
                BookmarkBadge()
                    .fill(Color.red)
                    .frame(width: 30, height: 40)
            }
        }
    }
}

struct BookmarkBadgeTileView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkBadgeTileView()
    }
}

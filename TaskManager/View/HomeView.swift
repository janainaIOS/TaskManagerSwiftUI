//
//  HomeView.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var taskList: [Task] = []
    @State private var addTaskTapped = false
    @State private var isLoading: Bool = true
    @State private var showSettingsView = false
    @State private var showAlertView = false
    @State private var alertMessage : String = ""
    @State private var selectedTask: Task?
    
    var body: some View {
        GeometryReader{ geometry in
            VStack() {
                HStack() {
                    VStack(alignment: .leading){
                        Button(action: {
                            withAnimation {
                                showSettingsView.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.primary)
                            
                        }
                        NavigationLink(destination : ContentView()) {
                            Text("Hello,")
                                .font(.largeTitle)
                                .padding(.top, 23)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.leading, 15)
                    Spacer()
                    if taskList.count > 0 {
                        VStack(alignment: .trailing) {
                            // Calculate completed task percentage
                            let completedTasks = taskList.filter { $0.completed }
                            CircularProgressView(targetProgress:  Double(completedTasks.count / taskList.count), color: Color.accentColor)
                            
                            Text("Tasks Completed")
                                .font(.caption)
                                .foregroundColor(.primary)
                                .padding(.top, 10)
                        }
                        .padding()
                    }
                }
                
                if isLoading {
                    ProgressView() // Loader while fetching data
                        .padding()
                        .onAppear {
                            refreshTaskList()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isLoading = false
                            }
                        }
                } else {
                    
                    if taskList.isEmpty {
                        EmptyTaskView()
                    } else {
                        List {
                            ForEach(taskList) { taskItem in
                                ZStack {
                                    HomeTileView(size: geometry.size, task: taskItem)
                                    NavigationLink(destination: AddTaskView(isForEdit: true, task: taskItem)) {
                                        EmptyView()
                                    }
                                    .buttonStyle(.plain)
                                    .opacity(0) // To remove default right arrow button
                                }
                                .listRowSeparator(.hidden) // Hide separator
                                
                                .swipeActions(edge: .leading) {
                                    Button {
                                        selectedTask = taskItem
                                        alertMessage = AlertMessages.completeAlert
                                        showAlertView = true
                                    } label: {
                                        Label("Complete", systemImage: "checkmark")
                                            .foregroundColor(.black)
                                            .tint(.green)
                                    }
                                    .tint(.white) // Clear background
                                }
                                .swipeActions(edge: .trailing) {
                                    Button() {
                                        selectedTask = taskItem
                                        alertMessage = AlertMessages.deleteAlert
                                        showAlertView = true
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 70))
                                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 0)
                                    }
                                }
                                
                            }
                            // .onMove(perform: moveTasks)
                            .onMove { indices, newOffset in
                                taskList.move(fromOffsets: indices, toOffset: newOffset)
                            }
                        }
                        .listStyle(.plain)
                        .background(.clear)
                    }
                    
                }
                
                Spacer()
                // add task button
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            addTaskTapped.toggle()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.accentColor)
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 0)
                        
                    }
                    .padding()
                    
                }
            }
            //Alerts
            .alert(isPresented: $showAlertView) {
                Alert(
                    title: Text(""),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("Yes"), action: alertActions),
                    secondaryButton: .cancel(Text("No"))
                )
            }
            //Navigation
            .fullScreenCover(isPresented: $addTaskTapped) {
                // .sheet(isPresented: self.$addTaskTapped) {
                AddTaskView(isForEdit: false, task: Task(title: "", descriptn: "", date: "", priority: "low"))
            }
            // Sidemenu
            Color.black.opacity(showSettingsView ? 0.5 : 0)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: showSettingsView)
                .onTapGesture {
                    withAnimation {
                        showSettingsView = false
                    }
                }
            SideMenu(isShowing: $showSettingsView, content: AnyView(SettingsView()))
        }
        .onAppear {
            refreshTaskList()
        }
    }
    
    func refreshTaskList() {
            taskList = coreDataManager.fetchTasks()
            isLoading = true
    }
    
    func alertActions() {
        if alertMessage.contains("delete") {
            coreDataManager.deleteTask(task: selectedTask ?? Task(title: "", descriptn: "", date: "", priority: "low")) { status in
                if status {
                    refreshTaskList()
                }
            }
        } else {
            selectedTask?.completed = true
            //update task in coredata
            coreDataManager.editTask(task: selectedTask ?? Task(title: "", descriptn: "", date: "", priority: "low")) { status in
                if status {
                    refreshTaskList()
                }
            }
        }
    
    }
}

#Preview {
    HomeView()
}

struct HomeTileView: View {
    @State var size: CGSize
    @State var task: Task
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Tile
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .frame(width: size.width * 0.9, height: 120)
                .shadow(color: Color.black.opacity(0.2), radius: 3)
                .overlay(
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(task.title)
                                .font(.title3)
                                .foregroundColor(.black)
                            
                            Label(task.date, systemImage: "calendar")
                                .font(.caption)
                                .labelStyle(.titleAndIcon)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 5) {
                            Spacer()
                            ZStack {
                                if task.completed {
                                    Rectangle()
                                        .strokeBorder(.black, lineWidth: 1.5)
                                        .frame(width: 25, height: 25)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                        .padding(15)
                )
            
            // Bookmark Badge
            ZStack {
                BookmarkBadge()
                    .fill(TaskPriority(rawValue: task.priority)?.color ?? .green1)
                    .frame(width: 30, height: 40)
                    .offset(x: -13, y: -5)
            }
        }
        
    }
}

struct EmptyTaskView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "tray.fill")
                .font(.largeTitle)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            Text(AlertMessages.taskListEmptyAlert)
                .font(.headline)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
    }
}


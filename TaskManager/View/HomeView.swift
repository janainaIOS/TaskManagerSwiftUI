//
//  HomeView.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = TaskViewModel()
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var taskList: [Task] = [] //Filtered tasks
    @State private var addTaskTapped = false
    @State private var isLoading: Bool = true
    @State private var showSettingsView = false
    @State private var showAlertView = false
    @State private var alertMessage : String = ""
    @State private var selectedTask: Task?
    @State private var selectedFilter: FilterOptions = .none
    @State private var showFilterSheet: Bool = false
    @State private var viewForSort: Bool = true
    
    var body: some View {
        GeometryReader{ geometry in
            VStack() {
                TopView(showSettingsView: $showSettingsView, allTaskList: $viewModel.allTaskList)
                
                if !viewModel.allTaskList.isEmpty {
                    FilterButtonView(viewForSort: $viewForSort, showFilterSheet: $showFilterSheet)
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
                    ZStack(alignment: .bottomTrailing) {
                        if taskList.isEmpty {
                            EmptyTaskView()
                        } else {
                            TaskListView(size: geometry.size, taskList: $taskList, addTaskTapped: $addTaskTapped, selectedTask: $selectedTask, showAlertView: $showAlertView, alertMessage: $alertMessage)
                               
                            // .transition(.scale.combined(with: .opacity)) // Fade-and-Scale Animation
                            // .animation(.spring, value: taskList)
                        }
                        FloatingButtonView(addTaskTapped: $addTaskTapped)
                    }
                }
            }
        .onChange(of: selectedFilter) {
            taskList = viewModel.filterTaskList(viewForSort: viewForSort, selectedFilter: selectedFilter)
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
                AddTaskView(isForEdit: false, task: Task(title: "", descriptn: "", date: "", priority: "low"))
                    .onDisappear {
                        isLoading = true
                    }
                // .transition(.scale)
                // .animation(.spring(), value: addTaskTapped) // Spring Animation for Task Details View
            }
            // Sort or Filter tasks
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView(selectedFilter: $selectedFilter, showFilterSheet: $showFilterSheet, viewForSort: $viewForSort)
            }
            
            SideMenuView(showSettingsView: $showSettingsView)
        }
        .onAppear {
            isLoading = true
        }
    }
    
    func refreshTaskList() {
        viewModel.allTaskList = coreDataManager.fetchTasks()
        taskList = viewModel.allTaskList
        //isLoading = true
    }
    
    func alertActions() {
        if var selectdTask = selectedTask,
           let index = taskList.firstIndex(where: { $0.id == selectdTask.id }) {
            if alertMessage.contains("delete") {
                
                coreDataManager.deleteTask(task: selectdTask) { status in
                    if status {
                        taskList.remove(at: index)
                        if let indexFromAllTasks = viewModel.allTaskList.firstIndex(where: { $0.id == selectdTask.id }) {
                            viewModel.allTaskList.remove(at: indexFromAllTasks)
                        }
                    }
                }
            } else {
                selectdTask.completed = true
                //update task in coredata
                coreDataManager.editTask(task: selectdTask) { status in
                    if status {
                        isLoading = true
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

struct SideMenuView: View {
    @Binding var showSettingsView: Bool
    
    var body: some View {
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
}

struct TopView: View {
    @Binding var showSettingsView: Bool
    @Binding var allTaskList: [Task]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Button(action: {
                    withAnimation {
                        showSettingsView.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                Text("Hello,")
                    .font(.largeTitle)
                    .padding(.top, 23)
                    .foregroundColor(.primary)
            }
            .padding(.leading, 15)
            
            Spacer()
            
            if allTaskList.count > 0 {
                VStack(alignment: .trailing) {
                    let completedTasks = allTaskList.filter { $0.completed }
                    CircularProgressView(targetProgress: Double(completedTasks.count) / Double(allTaskList.count), color: Color.accentColor)
                    
                    Text("Tasks Completed")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.top, 5)
                }
                .padding()
            }
        }
        .padding(5)
    }
}

struct TaskListView: View {
    @State var size : CGSize
    @Binding var taskList: [Task]
    @Binding var addTaskTapped: Bool
    @Binding var selectedTask: Task?
    @Binding var showAlertView: Bool
    @Binding var alertMessage: String
    
    var body: some View {
        List {
            ForEach(taskList) { taskItem in
                ZStack {
                    HomeTileView(size: size, task: taskItem)
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
            .onMove { indices, newOffset in
                taskList.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .listStyle(.plain)
        .background(.clear)
    }
}

struct HomeTileView: View {
    @State var size : CGSize
    @State var task: Task
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Tile
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
            //.frame(width: size.width * 0.9, height: 120)
                .frame(width: size.width.isNaN ? 0 : size.width * 0.9, height: 120)
            
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
                                .foregroundColor(.black)
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

struct FloatingButtonView: View {
    @Binding var addTaskTapped: Bool
    @State private var animate = false
    @State private var isAnimating = false // Track ongoing animation
    
    var body: some View {
        let animationDuration = 0.5
        
        Button(action: {
            isAnimating = true
            
            // First pulse
            withAnimation(.easeInOut(duration: animationDuration)) {
                animate.toggle()
            }
            
            // Second pulse
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                withAnimation(.easeInOut(duration: animationDuration)) {
                    animate.toggle()
                }
            }
            
            // Animation ended
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration * 2) {
                isAnimating = false
                addTaskTapped.toggle()
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.accentColor)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 0)
                .scaleEffect(animate ? 1.3 : 1.0)
                .animation(.easeOut(duration: animationDuration), value: animate)
        }
        .padding()
        .zIndex(1)
        .accessibilityIdentifier("AddTaskButton")
        .accessibilityValue(isAnimating ? "Animating" : "Normal")
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

struct FilterButtonView: View {
    @Binding var viewForSort: Bool
    @Binding var showFilterSheet: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                viewForSort = true
                withAnimation {
                    showFilterSheet.toggle()
                }
            }) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            .accessibilityIdentifier("SortButton")
            Button(action: {
                viewForSort = false
                withAnimation {
                    showFilterSheet.toggle()
                }
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            .accessibilityIdentifier("FilterButton")
        }
        .padding(.bottom, 15)
        .padding(.trailing, 20)
    }
}

struct FilterSheetView: View {
    @Binding var selectedFilter: FilterOptions
    @Binding var showFilterSheet: Bool
    @Binding var viewForSort: Bool
    
    var body: some View {
        VStack {
            Text(viewForSort ? "Sort By" : "Select Filter")
                .font(.headline)
                .padding()
            
            Divider()
            let filtersArray: [FilterOptions] = viewForSort ? [.title, .dueDate, .priority] : [.all, .completed, .pending]
            ForEach(filtersArray, id: \.self) { option in
                FilterSheetOptionView(option: option, selectedFilter: $selectedFilter, showFilterSheet: $showFilterSheet)
            }
        }
        .padding()
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}

struct FilterSheetOptionView: View {
    let option: FilterOptions
    @Binding var selectedFilter: FilterOptions
    @Binding var showFilterSheet: Bool
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedFilter = option
                showFilterSheet = false
            }
        }) {
            Text(option.rawValue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedFilter == option ? ColorManager.currentColor.opacity(0.2) : Color.clear)
                .cornerRadius(15)
        }
        .foregroundColor(selectedFilter == option ? ColorManager.currentColor : .primary)
    }
}

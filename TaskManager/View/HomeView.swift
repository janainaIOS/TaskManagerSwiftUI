//
//  HomeView.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var allTaskList: [Task] = [] //All saved tasks
    @State private var taskList: [Task] = [] //Filtered tasks
    @State private var addTaskTapped = false
    @State private var isLoading: Bool = true
    @State private var showSettingsView = false
    @State private var showAlertView = false
    @State private var alertMessage : String = ""
    @State private var selectedTask: Task?
    @State private var selectedFilter: FilterOptions = .all
    @State private var showFilterSheet: Bool = false
    @State private var viewForSort: Bool = true
    @AppStorage("appThemeColor") private var appThemeColor: String = ThemeColor.grape.rawValue
    
    var body: some View {
        GeometryReader{ geometry in
            VStack() {
                TopView(showSettingsView: $showSettingsView, allTaskList: $allTaskList)
                
                if !taskList.isEmpty {
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
                                .onChange(of: selectedFilter) {
                                    if viewForSort {
                                        taskList = sortTasks()
                                    } else {
                                        taskList = filterTasks()
                                    }
                                }
                            // .transition(.scale.combined(with: .opacity)) // Fade-and-Scale Animation
                            // .animation(.spring, value: taskList)
                        }
                        FloatingButtonView(addTaskTapped: $addTaskTapped)
                    }
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
        allTaskList = coreDataManager.fetchTasks()
        taskList = allTaskList
        //isLoading = true
    }
    
    func alertActions() {
        if var selectdTask = selectedTask,
           let index = taskList.firstIndex(where: { $0.id == selectdTask.id }) {
        if alertMessage.contains("delete") {
            
                coreDataManager.deleteTask(task: selectdTask) { status in
                    if status {
                         taskList.remove(at: index)
                       // taskList = taskList
                        if let indexFromAllTasks = allTaskList.firstIndex(where: { $0.id == selectdTask.id }) {
                            allTaskList.remove(at: indexFromAllTasks)
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
    
    /*
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
     */
    
    
    // Filter tasks
    func filterTasks() -> [Task] {
        taskList = allTaskList
        switch selectedFilter {
        case .completed:
            return taskList.filter { $0.completed }
        case .pending:
            return taskList.filter { !$0.completed }
        default:
            return taskList
        }
    }
    
    // Sort tasks
    func sortTasks() -> [Task] {
        taskList = allTaskList
        switch selectedFilter {
        case .title:
            return taskList.sorted { $0.title < $1.title }
        case .dueDate:
            return taskList.sorted { $0.date.formatToDate(inputFormat: .ddMMMyyyy) < $1.date.formatToDate(inputFormat: .ddMMMyyyy) }
        case .priority:
            let priorityOrder = ["high", "medium", "low"]
            return taskList.sorted {
                priorityOrder.firstIndex(of: $0.priority) ?? Int.max <
                    priorityOrder.firstIndex(of: $1.priority) ?? Int.max
            }
        default:
            return taskList
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
    
    var body: some View {
        Button(action: {
            //single pulse animation
            let animationDuration = 0.4
            for delay in [0, animationDuration] {
                withAnimation(.easeInOut(duration: animationDuration).delay(delay)) {
                    animate.toggle()
                    
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                addTaskTapped.toggle()
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.accentColor)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 0)
                .scaleEffect(animate ? 1.3 : 1.0)
                .animation(.easeOut(duration: 0.4), value: animate)
        }
        .padding()
        .zIndex(1) // Keeps button above the list
    }
}

/*
 
 struct FloatingButtonView: View {
 @Binding var addTaskTapped: Bool
 
 var body: some View {
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
 .zIndex(1) // Keeps button above the list
 }
 }
 */
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

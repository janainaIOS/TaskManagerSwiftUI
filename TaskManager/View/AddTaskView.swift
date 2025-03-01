//
//  AddTaskView.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import SwiftUI
import SimpleToast

struct AddTaskView: View {
    
    @StateObject private var coreDataManager = CoreDataManager.shared
    @Environment(\.dismiss) var dismiss
    @State var isForEdit = false
    @State var task: Task
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    @State private var showToast = false
    @State private var toastMessage : String = ""
    @Namespace private var animation
    
    var body: some View {
        
        VStack {
            headerView
            InputTextView(title: "Title", value: $task.title)
            InputTextView(title: "Description", value: $task.descriptn, isTextEditor: true)
            DueDateView(selectedDate: $selectedDate, showDatePicker: $showDatePicker)
            prorityView
            saveButtonView
        }
        .showToast(isPresented: $showToast, message: toastMessage)
        .padding()
        .navigationBarBackButtonHidden()
        .overlay {
            datePickerView()
        }
        .onAppear {
            selectedDate = task.date.formatToDate(inputFormat: .ddMMMyyyy)
        }
    }
    
    private var headerView: some View {
        HStack{
            Button {
                self.dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            Spacer()
            Text(isForEdit ? "Edit Task" : "New Task")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
            Spacer()
            MenuView(isForEdit: $isForEdit, task: $task)
        }
        .padding(.bottom, 30)
    }
    
    private var prorityView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Priority")
                .font(.footnote)
                .foregroundColor(.gray)
            
            prioritySelector
        }
    }
    
    private var saveButtonView: some View {
        GeometryReader { geometry in
            Button(action: {
                addTaskAction()
            }, label: {
                Text(isForEdit ? "Save" : "Add Task")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundColor(.white)
            })
            .accessibilityIdentifier("SaveTaskButton")
            .tint(ColorManager.currentColor)
            .buttonStyle(.borderedProminent)
            .padding(.vertical, 30)
            Spacer()
        }
    }
    
    // Priority selector view
    private var prioritySelector: some View {
        HStack(spacing: 12) {
            ForEach(TaskPriority.allCases, id: \.self) { type in
                let isSelected = task.priority == type.rawValue
                
                Text(type.rawValue)
                    .font(.callout)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(priorityBackground(isSelected, color: type.color))
                    .contentShape(Capsule())
                    .onTapGesture {
                        hideKeyboard()
                        withAnimation {
                            task.priority = type.rawValue
                        }
                    }
            }
        }
    }
    
    // Priority background view
    private func priorityBackground(_ isSelected: Bool, color: Color) -> some View {
        Group {
            if isSelected {
                Capsule()
                    .fill(color)
                    .strokeBorder(.primary)
                    .matchedGeometryEffect(id: "TYPE", in: animation)
            } else {
                Capsule()
                    .fill(color)
                
            }
        }
    }
    
    private func datePickerView() -> some View {
        ZStack {
            if showDatePicker {
                
                // Full-screen transparent tap area
                Color.black.opacity(showDatePicker ? 0.8 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            task.date = selectedDate.formatDate(outputFormat: .ddMMMyyyy)
                            showDatePicker = false
                        }
                    }
                // DatePicker
                VStack {
                    DatePicker("",
                               selection: $selectedDate,
                               in: Date.now...,
                               displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .accentColor(ColorManager.currentColor)
                    .labelsHidden()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .white })) // Background color dynamic
                            .shadow(radius: 5)
                    )
                    .padding()
                    
                    Button("Done") {
                        task.date = selectedDate.formatDate(outputFormat: .ddMMMyyyy)
                        showDatePicker = false
                    }
                    .padding()
                    .background(ColorManager.currentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .animation(.easeInOut, value: showDatePicker)
    }
    
    //Add Task button Action
    func addTaskAction() {
        //title textfield validation
        if task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            toastMessage = AlertMessages.titleEmptyAlert
            showToast = true
        } else {
            // format task date
            task.date = selectedDate.formatDate(outputFormat: .ddMMMyyyy)
            
            if isForEdit {
                //update task in coredata
                coreDataManager.editTask(task: task) { status in
                    if status {
                        self.dismiss()
                    }
                }
            } else {
                //create new task in coredata
                coreDataManager.addTask(task: task) { status in
                    if status {
                        self.dismiss()
                    }
                }
            }
        }
    }
}

struct InputTextView: View {
    var title: String
    @Binding var value: String
    var isTextEditor: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.gray)
            if isTextEditor {
                ZStack {
                    Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .gray }).opacity(0.05)
                        .cornerRadius(8)
                    TextEditor(text: $value)
                        .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(8)
                }
            } else {
                TextField("", text: $value)
                    .padding(.top, 8)
            }
        }
        Divider().padding(.vertical, 10)
    }
}

struct DueDateView: View {
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Due Date")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Text(selectedDate.formatDate(outputFormat: .ddMMMyyyy))
                .font(.footnote)
                .fontWeight(.semibold)
                .padding(.top, 8)
                .padding(.leading, 28)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottomLeading) {
            Button {
                hideKeyboard()
                showDatePicker.toggle()
            } label: {
                Image(systemName: "calendar")
                    .foregroundColor(.primary)
            }
            .accessibilityIdentifier("calendarButton")
        }
        
        Divider() .padding(.vertical, 10)
    }
}

struct MenuView: View {
    @Binding var isForEdit: Bool
    @Binding var task: Task
    @StateObject private var coreDataManager = CoreDataManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showAlertView = false
    @State private var alertMessage : String = ""
    
    var body: some View {
        
        // Menu appears when tapping more button
        Menu {
            if isForEdit && !task.completed {
                Button("Mark as Complete") {
                    alertMessage = AlertMessages.completeAlert
                    showAlertView = true
                }
                .foregroundColor(.primary)
            }
            Button("Delete Task") {
                alertMessage = AlertMessages.deleteAlert
                showAlertView = true
            }
            .foregroundColor(.primary)
        } label: {
            Image(systemName: "ellipsis")
                .font(.title)
                .foregroundColor(.primary)
                .padding()
        }
        .alert(isPresented: $showAlertView) {
            Alert(
                title: Text(""),
                message: Text(alertMessage),
                primaryButton: .default(Text("Yes"), action: alertActions),
                secondaryButton: .cancel(Text("No"))
            )
        }
    }
    
    func alertActions() {
        if alertMessage.contains("delete") {
            deleteAction()
        } else {
            markCompleteAction()
        }
    }
    
    func deleteAction() {
        coreDataManager.deleteTask(task: task) { status in
            if status {
                self.dismiss()
            }
        }
    }
    
    func markCompleteAction() {
        task.completed = true
        //update task in coredata
        coreDataManager.editTask(task: task) { status in
            if status {
                self.dismiss()
            }
        }
    }
}

#Preview {
    AddTaskView(task: Task(title: "", descriptn: "", date: "", priority: "low"))
}

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
        GeometryReader { geometry in
            VStack {
                Text(isForEdit ? "Edit Task" : "New Task")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        Button {
                            self.dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Title")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    TextField("", text: $task.title)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
                Divider()
                    .padding(.vertical, 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    ZStack {
                        Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .gray }).opacity(0.05) // Background color
                            .cornerRadius(8)
                        TextEditor(text: $task.descriptn)
                            .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .padding(8)
                    }
                }
                Divider()
                    .padding(.vertical, 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Date")
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
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Priority")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    prioritySelector
                }
                
                Button(action: {
                    addTaskAction()
                }, label: {
                    Text(isForEdit ? "Save" : "Add Task")
                        .font(.subheadline)
                        .frame(width: geometry.size.width * 0.85, height: 40)
                        .foregroundColor(.white)
                })
                .tint(.accentColor)
                .buttonStyle(.borderedProminent)
                .padding(.vertical, 33)
                Spacer()
            }
            
        }
        .showToast(isPresented: $showToast, message: toastMessage)
        .padding()
        .navigationBarBackButtonHidden()
        .overlay {
            ZStack {
                if showDatePicker {
                    
                    // Full-screen transparent tap area
                    Color.black.opacity(showDatePicker ? 0.8 : 0)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
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
                        .accentColor(.accentColor)
                        .labelsHidden()
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .white })) // Background color dynamic
                                .shadow(radius: 5)
                        )
                        .padding()
                        
                        Button("Done") {
                            showDatePicker = false
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .animation(.easeInOut, value: showDatePicker)
        }
        
    }
    
    // Priority selector view
    var prioritySelector: some View {
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
                        withAnimation {
                            task.priority = type.rawValue
                        }
                    }
            }
        }
    }
    
    // Priority background view
    func priorityBackground(_ isSelected: Bool, color: Color) -> some View {
        Group {
            if isSelected {
                Capsule()
                    .fill(color)
                    .strokeBorder(.black)
                    .matchedGeometryEffect(id: "TYPE", in: animation)
            } else {
                Capsule()
                    .fill(color)
                
            }
        }
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

#Preview {
    AddTaskView(task: Task(title: "", descriptn: "", date: "", priority: "low"))
}

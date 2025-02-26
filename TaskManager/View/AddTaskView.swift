//
//  AddTaskView.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import SwiftUI

struct AddTaskView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var isForEdit = false
    @State var task: Task
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    @State private var addTaskTapped = false
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
                                .foregroundColor(.black)
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
                    TextEditor(text: $task.descriptn)
                        .frame(height: 100)
                        .background(Color.gray.opacity(0.2))
                      //  .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
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
                        showDatePicker.toggle()
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(.black)
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
                    addTaskTapped = true
                }, label: {
                    Text("Add Task")
                        .font(.subheadline)
                        .frame(width: geometry.size.width * 0.85, height: 40)
                        .foregroundColor(.white)
                })
                .tint(.accent)
                .buttonStyle(.borderedProminent)
                .padding(.vertical, 33)
            }
            .padding()
            .overlay {
                ZStack {
                    if showDatePicker {
                        // Full-screen transparent tap area with blur effect
                        Color.clear
                            .background(.ultraThinMaterial)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showDatePicker = false
                            }
                        
                        // DatePicker
                        VStack {
                            DatePicker("",
                                       selection: $selectedDate,
                                       in: Date.now...,
                                       displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .accentColor(.accent)
                            .labelsHidden()
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 5))
                            .padding()
                            
                            Button("Done") {
                                showDatePicker = false
                            }
                            .padding()
                            .background(.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .animation(.easeInOut, value: showDatePicker)
                
            }
        }
    }
    
    // Extracted Priority Selector
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
    
    // Extracted Background View
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
}

#Preview {
    AddTaskView(task: Task(title: "", descriptn: "", date: "", priority: "low"))
}

//
//  TaskViewModel.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import Foundation

final class TaskViewModel: ObservableObject {
    @Published var allTaskList: [Task] = [] //All saved tasks
    
    func filterTaskList(viewForSort: Bool, selectedFilter: FilterOptions) -> [Task] {
        return viewForSort ? sortTasks(selectedFilter: selectedFilter) : filterTasks(selectedFilter: selectedFilter)
     }
    
    // Filter tasks
    func filterTasks(selectedFilter: FilterOptions) -> [Task] {
        switch selectedFilter {
        case .completed:
            return allTaskList.filter { $0.completed }
        case .pending:
            return allTaskList.filter { !$0.completed }
        default:
            return allTaskList
        }
    }
    
    // Sort tasks
    func sortTasks(selectedFilter: FilterOptions) -> [Task] {
        switch selectedFilter {
        case .title:
            return allTaskList.sorted { $0.title < $1.title }
        case .dueDate:
            return allTaskList.sorted { $0.date.formatToDate(inputFormat: .ddMMMyyyy) < $1.date.formatToDate(inputFormat: .ddMMMyyyy) }
        case .priority:
            let priorityOrder = ["high", "medium", "low"]
            return allTaskList.sorted {
                priorityOrder.firstIndex(of: $0.priority) ?? Int.max <
                    priorityOrder.firstIndex(of: $1.priority) ?? Int.max
            }
        default:
            return allTaskList
        }
    }
}

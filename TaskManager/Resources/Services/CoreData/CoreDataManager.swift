//
//  CoreDataManager.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import Foundation
import CoreData

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    private let container: NSPersistentContainer
    
    private init() {
        self.container = PersistenceController.shared.container
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Save Context
    private func saveContext() -> Bool {
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                let nserror = error as NSError
                debugPrint("Save failed: \(nserror), \(nserror.userInfo)")
                return false
            }
        }
        return false
    }
    
    // MARK: - Fetch saved Tasks
    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<DBTask> = DBTask.fetchRequest()
            do {
                let dbTasks = try context.fetch(request)
                let taskList = dbTasks.map { dbTask in
                    Task(
                        id: dbTask.id ?? "",
                        title: dbTask.title ?? "",
                        descriptn: dbTask.descriptn ?? "",
                        date: dbTask.date ?? "",
                        priority: dbTask.priority ?? "",
                        completed: dbTask.completed,
                        addedDate: dbTask.addedDate ?? Date()
                    )
                }
                print("tasks \(taskList.count)")
                return taskList
            } catch {
                print("Failed to fetch tasks: \(error.localizedDescription)")
                return []
            }
    }
    
    func fetchDBTasks() -> [DBTask] {
        let request: NSFetchRequest<DBTask> = DBTask.fetchRequest()
        do {
            let tasks = try context.fetch(request)
            print("db tasks \(tasks.count)")
            return tasks
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }
    
    // MARK: - Add Task
    func addTask(task: Task, completion:((Bool)->Void)) {
        let dbTask       = DBTask(context: context)
        dbTask.addedDate = Date()
        dbTask.id        = task.id
        dbTask.title     = task.title
        dbTask.descriptn = task.descriptn
        dbTask.date      = task.date
        dbTask.priority  = task.priority
        dbTask.completed = task.completed
        completion(saveContext())
    }
    
    // MARK: - Edit Task
    func editTask(task: Task, completion: ((Bool) -> Void)) {
        let fetchRequest: NSFetchRequest<DBTask> = DBTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let dbTask = results.first {
                dbTask.title     = task.title
                dbTask.descriptn = task.descriptn
                dbTask.date      = task.date
                dbTask.priority  = task.priority
                dbTask.completed = task.completed

                completion(saveContext())
            } else {
                print("Task not found")
                completion(false)
            }
        } catch {
            print("Failed to fetch task: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(task: Task, completion: ((Bool) -> Void)) {
        let fetchRequest: NSFetchRequest<DBTask> = DBTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let dbTask = results.first {
                context.delete(dbTask)
                completion(saveContext())
            } else {
                print("Task not found")
                completion(false)
            }
        } catch {
            print("Failed to fetch task for deletion: \(error)")
            completion(false)
        }
    }

}

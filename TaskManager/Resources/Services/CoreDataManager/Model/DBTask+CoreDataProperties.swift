//
//  DBTask+CoreDataProperties.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//
//

import Foundation
import CoreData


extension DBTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBTask> {
        return NSFetchRequest<DBTask>(entityName: "DBTask")
    }

    @NSManaged public var addedDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var descriptn: String?
    @NSManaged public var date: String?
    @NSManaged public var priority: String?
    @NSManaged public var id: String?
    @NSManaged public var completed: Bool

}

extension DBTask : Identifiable {

}

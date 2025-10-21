//
//  CoreDataStack.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import CoreData

final class CoreDataStack {
    let container: NSPersistentContainer
    init(modelName:String = "DocumentsModel") {
        container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let err = error {
                fatalError("❌ CoreData load error \(err)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
}

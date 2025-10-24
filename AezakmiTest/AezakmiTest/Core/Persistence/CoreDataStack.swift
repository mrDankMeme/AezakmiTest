//
//  CoreDataStack.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import CoreData


final class CoreDataStack {
    
    // MARK: - Public
    
    let container: NSPersistentContainer
    
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    init(modelName: String = "DocumentsModel") {
        container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores { _, error in
            if let err = error {
                fatalError("❌ CoreData load error: \(err.localizedDescription)")
            }
        }
        
        
        configureContexts()
    }
    
    // MARK: - Private
    
    private func configureContexts() {
        let ctx = container.viewContext
        ctx.automaticallyMergesChangesFromParent = true
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let bg = container.newBackgroundContext()
        bg.automaticallyMergesChangesFromParent = true
        bg.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return bg
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { ctx in
            ctx.automaticallyMergesChangesFromParent = true
            ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(ctx)
        }
    }
    
    func saveContextIfNeeded() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        do { try ctx.save() }
        catch { print("❌ CoreData save error: \(error.localizedDescription)") }
    }
}

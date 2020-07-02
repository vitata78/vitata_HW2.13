//
//  StorageManager.swift
//  vitata_HW2.13
//
//  Created by Andrew Tolstov on 7/1/20.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "vitata_HW2_13")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveTask(name: String) {
        
        let viewContext = persistentContainer.viewContext
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: viewContext) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Task else { return }
        
        task.name = name
        saveContext()
    }
    
    func deleteTask(task: Task) {
        
        persistentContainer.viewContext.delete(task)
        saveContext()
        
    }
    
    func fetchData() -> [Task] {
        let viewContext = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        var tasks: [Task] = []
        do {
            tasks = try viewContext.fetch(fetchRequest)
            
        } catch let error {
            print(error)
        }
        
        return tasks
        
    }
    
}

//
//  DataController.swift
//  VirtualTourist
//
//  Created by Tye Porter on 5/28/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation
import CoreData

/// A class that encapsulates the core data stack setup and its functionality
class DataController {
    
    /// `NSPersistentContainer` instance that helps load the persistent store and manage its contexts
    let persistentContainer: NSPersistentContainer
    /// `NSManagedObjectContext` owned by `persistentConteiner` associated with the main queue
    var viewContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    /// `NSManagedObjectContext` owned by `persistentConteiner` associated with a private (background) queue
    var backgroundContext: NSManagedObjectContext!
    
    init(modelName: String) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    private func configureContexts() {
        self.backgroundContext = self.persistentContainer.newBackgroundContext()
        
        self.viewContext.automaticallyMergesChangesFromParent = true
        self.backgroundContext.automaticallyMergesChangesFromParent = true
        
        self.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        self.backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    /// This method loads the `DataController`'s persistent store and configures its contexts. The method will then run a completion handler if its given one
    func load(completionHandler: (() -> Void)? = nil) {
        self.persistentContainer.loadPersistentStores { (storeDescription: NSPersistentStoreDescription, error: Error?) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            self.configureContexts()
            completionHandler?()
        }
    }
    
}

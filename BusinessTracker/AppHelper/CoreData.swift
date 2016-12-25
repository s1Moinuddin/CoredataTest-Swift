//
//  CoreData.swift
//  BusinessTracker
//
//  Created by Shuvo on 10/24/16.
//  Copyright © 2016 Shuvo. All rights reserved.
//

import Foundation
import CoreData

class CoreData {
    
    let model = "BusinessTracker"
    
    // Applications default directory address
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // 1
        let modelURL = NSBundle.mainBundle().URLForResource(self.model, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.model)
        
        do {
            // If your looking for any kind of migration then here is the time to pass it to the options
            let options = [NSMigratePersistentStoresAutomaticallyOption:true]
            
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
            
        } catch let  error as NSError {
            fatalError("Error Adding persistence store: \(error.localizedDescription)")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        //         Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        
        let coordinator = self.persistentStoreCoordinator
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }()
    
    // if there is any change in the context save it
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                fatalError("Error Saving Context: \(error.localizedDescription)")
                
            }
        }
    }
}
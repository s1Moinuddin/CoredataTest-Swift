//
//  Business+CoreDataProperties.swift
//  BusinessTracker
//
//  Created by Shuvo on 10/25/16.
//  Copyright © 2016 Shuvo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Business {

    @NSManaged var name: String?
    @NSManaged var instalationCost: String?
    @NSManaged var product: NSSet?

}

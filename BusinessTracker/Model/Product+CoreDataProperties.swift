//
//  Product+CoreDataProperties.swift
//  BusinessTracker
//
//  Created by Shuvo on 10/26/16.
//  Copyright © 2016 Shuvo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Product {

    @NSManaged var cost: String?
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var business: Business?

}

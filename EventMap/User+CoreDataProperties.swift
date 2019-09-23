//
//  User+CoreDataProperties.swift
//  
//
//  Created by BACHIR-CHERIF Mohamed on 05/12/2017.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var uID: String?

}

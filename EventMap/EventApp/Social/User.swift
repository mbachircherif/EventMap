//
//  User.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 05/12/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import Foundation
import CoreData

class Users {
    
    static let sharedInstance = Users()
    
    var userData = [User]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func addUser(uID: String) {
        
        //https://forums.developer.apple.com/thread/74186
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
        user.uID = uID
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    func fetchUserData() -> [User] {
        do {
            userData = try context.fetch(User.fetchRequest())
        }catch {
            print("Error fetching data from CoreData")
        }
        return userData
    }
    
}

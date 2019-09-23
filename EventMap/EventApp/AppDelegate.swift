//
//  AppDelegate.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 23/03/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import CoreData

struct userData {
    static var userObj: User?
    static var uID: String?
    static var uBio: String?
    static var uName: String?
    static var uOccupation: String?
    static var uEvent: [String: Bool]?
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?
    var refDatabase : DatabaseReference?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .default
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyAULqlDxQGW47Rf_8T3ygWrPxyNnh-kDUQ")
        GMSPlacesClient.provideAPIKey("AIzaSyAULqlDxQGW47Rf_8T3ygWrPxyNnh-kDUQ")
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                
                // Define the Ref Database
                self.refDatabase =  Database.database().reference(withPath: "events")
                
                /// If authentifiate
                
                /*
                 - Essayer de fetch avec uid de l'utilisateur qui sera l'entrée de l'attribut uID de l'entité User
                 - Try to add new entry to Core Data if the uid's User doesn't exist
                 */
                
                let fetchedUserData = Users.sharedInstance.fetchUserData()[0]
                
                userData.userObj = fetchedUserData
                userData.uID = fetchedUserData.uID
                
                /*  Add listener to firebase user path*/
                
                self.refDatabase?.child(userData.uID!).observe(.value, with: { (snapshot) in
                    
                /* Stuff to update the Core Data user interface */
                
                 let UserDatavalues = snapshot.value as? NSDictionary
                    userData.uBio = UserDatavalues?["bioUser"] as? String
                    userData.uName =  UserDatavalues?["fullname"] as? String
                    userData.uOccupation = UserDatavalues?["occupation"] as? String
                    userData.uEvent = UserDatavalues?["event"] as? [String: Bool]
                    
                }, withCancel: { (error) in
                    print (error)
                })
                
                let rootMapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                self.window?.rootViewController = rootMapViewController
            } else {
                self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginScreen")
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
        refDatabase?.removeAllObservers()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is addEventVC {
            if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "addEventVC_id") {
                let navigationController = UINavigationController(rootViewController: newVC)

                tabBarController.present(navigationController, animated: true)
                return false
            }
        }
        return true
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
    



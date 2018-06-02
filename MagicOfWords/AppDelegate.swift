//
//  AppDelegate.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 05/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import RealmSwift

var realm: Realm = try! Realm()
let wordListConfig = Realm.Configuration(
    fileURL: URL(string: Bundle.main.path(forResource: "WordList", ofType: "realm")!),
    readOnly: true)

// Open the Realm with the configuration
let realmWordList:Realm = try! Realm(configuration: wordListConfig)

let mandatoryConfig = Realm.Configuration(
    // Get the path to the bundled file
    fileURL: URL(string: Bundle.main.path(forResource: "Mandatory", ofType:"realm")!),
    // Open the file in read-only mode as application bundles are not writeable
    readOnly: true)

// Open the Realm with the configuration
let realmMandatory: Realm = try! Realm(configuration: mandatoryConfig)


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        Realm.Configuration.defaultConfiguration = Realm.Configuration(
//            schemaVersion: 2,   // new param in PlayerModel: onlineCompetitionEnabled (Bool)
//            
//            migrationBlock: { migration, oldSchemaVersion in
//                switch oldSchemaVersion {
//                case 0, 1:
//                    // migrate PlayerModel
//                    migration.enumerateObjects(ofType: GameDataModel.className()) { oldObject, newObject in
//                        if oldObject == nil {
//                            newObject!["score"] = 0 // (oldObject!["levelID"] as! Int) / MaxColorValue
//                        }
//                    }
//                    migration.enumerateObjects(ofType: BasicDataModel.className()) { oldObject, newObject in
//                        if oldObject == nil {
//                            newObject!["myName"] = "" // (oldObject!["levelID"] as! Int) / MaxColorValue
//                        }
//                    }
//               default:
//                    break
//                }
//        })
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
    }


}


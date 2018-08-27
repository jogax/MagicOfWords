//
//  AppDelegate.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 05/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import RealmSwift

// for Standard Using
//#if !GENERATEWORDLIST && !GENERATEMANDATORY
//let defaultConfig = Realm.Configuration(
//    objectTypes: [GameDataModel.self, RoundDataModel.self, BasicDataModel.self])

// for Generating WordList DB
//let defaultConfig = Realm.Configuration(
//    objectTypes: [WordListModel.self])

// for generating Mandatory Words
//let defaultConfig = Realm.Configuration(
//    objectTypes: [MandatoryModel.self])
//var realm: Realm = try! Realm(configuration: defaultConfig)
//#endif
//
#if !GENERATELETTERFREQUENCY && !GENERATEWORDLIST && !GENERATEMANDATORY
var realm: Realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
#endif
let wordListConfig = Realm.Configuration(
    fileURL: URL(string: Bundle.main.path(forResource: "WordList", ofType: "realm")!),
    readOnly: true,
    objectTypes: [WordListModel.self])

// Open the Realm with the configuration
let realmWordList:Realm = try! Realm(configuration: wordListConfig)

let mandatoryConfig = Realm.Configuration(
    // Get the path to the bundled file
    fileURL: URL(string: Bundle.main.path(forResource: "Mandatory", ofType:"realm")!),
    // Open the file in read-only mode as application bundles are not writeable
    readOnly: true,
    objectTypes: [MandatoryModel.self])

// Open the Realm with the configuration
let realmMandatory: Realm = try! Realm(configuration: mandatoryConfig)


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 3,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 3) {
                    migration.deleteData(forType: GameDataModel.className())
                    migration.deleteData(forType: RoundDataModel.className())
                    migration.deleteData(forType: BasicDataModel.className())
                }
            },
            objectTypes: [GameDataModel.self, RoundDataModel.self, BasicDataModel.self]

        )
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        

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


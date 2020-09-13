//
//  AppDelegate.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 05/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import RealmSwift
import Reachability
import AVFoundation

//#if !GENERATELETTERFREQUENCY && !GENERATEWORDLIST && !GENERATEMANDATORY && !CREATEMANDATORY && !CREATEWORDLIST

var realm: Realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
//#endif

//let realmHints = try! Realm(configuration: myHintConfig)
//
//class RealmConfiguration {
//    static func hintsConfiguration() -> Realm.Configuration {
//        var config = Realm.Configuration(
//            objectTypes: [HintsModel.self]
//        )
//        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("HintsModel.realm")
//        return config
//    }
//}

let wordListConfig = Realm.Configuration(
    fileURL: URL(string: Bundle.main.path(forResource: "WordList", ofType: "realm")!),
    readOnly: true,
    objectTypes: [WordListModel.self])
var reachability: Reachability?
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

let mandatoryListConfig  = Realm.Configuration(
    // Get the path to the bundled file
//    fileURL: URL(string: Bundle.main.path(forResource: "MandatoryList", ofType:"realm")!),
    fileURL: URL(string: Bundle.main.path(forResource: "Hints", ofType:"realm")!),
    // Open the file in read-only mode as application bundles are not writeable
    readOnly: true,
    schemaVersion: 1, // new item words

    objectTypes: [HintModel.self])

//// Open the Realm with the configuration
let realmMandatoryList: Realm = try! Realm(configuration: mandatoryListConfig)



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        Compressing Realm DB if neaded
        func updateHints() {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let HintsURL = documentsURL.appendingPathComponent("Hints.realm")
            let config = Realm.Configuration(
                fileURL: HintsURL,
                schemaVersion: 1, // new item words
                shouldCompactOnLaunch: { totalBytes, usedBytes in
                    // totalBytes refers to the size of the file on disk in bytes (data + free space)
                    // usedBytes refers to the number of bytes used by data in the file

                    // Compact if the file is over 100MB in size and less than 50% 'used'
                    let oneMB = 10 * 1024 * 1024
                    return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
            },
                objectTypes: [HintModel.self])
            do {
                // Realm is compacted on the first open if the configuration block conditions were met.
                _ = try Realm(configuration: config)
            } catch {
                print("error")
                // handle error compacting or opening Realm
            }

//            let gamesRealm = try! Realm(configuration: config)
         }
        
        func updateWordList() {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let WordListURL = documentsURL.appendingPathComponent("WordList.realm")
            let config = Realm.Configuration(
                fileURL: WordListURL,
                schemaVersion: 0, // new item words
                shouldCompactOnLaunch: { totalBytes, usedBytes in
                    // totalBytes refers to the size of the file on disk in bytes (data + free space)
                    // usedBytes refers to the number of bytes used by data in the file

                    // Compact if the file is over 100MB in size and less than 50% 'used'
                    let oneMB = 10 * 1024 * 1024
                    return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
            },
                objectTypes: [WordListModel.self])
            do {
                // Realm is compacted on the first open if the configuration block conditions were met.
                _ = try Realm(configuration: config)
            } catch {
                print("error")
                // handle error compacting or opening Realm
            }

//            let wordListRealm = try! Realm(configuration: config)
         }
        
        func updateMandatory() {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let MandatoryURL = documentsURL.appendingPathComponent("Mandatory.realm")
            let config = Realm.Configuration(
                fileURL: MandatoryURL,
                schemaVersion: 0, // new item words
                shouldCompactOnLaunch: { totalBytes, usedBytes in
                    // totalBytes refers to the size of the file on disk in bytes (data + free space)
                    // usedBytes refers to the number of bytes used by data in the file

                    // Compact if the file is over 100MB in size and less than 50% 'used'
                    let oneMB = 10 * 1024 * 1024
                    return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
            },
                objectTypes: [WordListModel.self])
            do {
                // Realm is compacted on the first open if the configuration block conditions were met.
                _ = try Realm(configuration: config)
            } catch {
                print("error")
                // handle error compacting or opening Realm
            }

//            let mandatoryRealm = try! Realm(configuration: config)
         }
        

//        updateHints()
//        updateWordList()
//        updateMandatory()
        
        let config1 = Realm.Configuration(shouldCompactOnLaunch: { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file

            // Compact if the file is over 100MB in size and less than 50% 'used'
            let oneMB = 1024 * 1024
            return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
        })
        do {
            // Realm is compacted on the first open if the configuration block conditions were met.
            _ = try Realm(configuration: config1)
        } catch {
//            print("error")
            // handle error compacting or opening Realm
        }
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            //            schemaVersion: 3,
            schemaVersion: 78, // used since 2020-09-08
//            schemaVersion: 60, // used since 2020-02-05
//            schemaVersion: 59, // used since 2019-08-30
//            schemaVersion: 30, // optimize BasicDataModel
//            schemaVersion: 27, // start with Game Center
//            schemaVersion: 26, // buttontype not needed any more
           // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                switch oldSchemaVersion {
                case 0...18:
                    migration.deleteData(forType: GameDataModel.className())
                    migration.deleteData(forType: RoundDataModel.className())
                    migration.deleteData(forType: BasicDataModel.className())
//                case 19:
//                    migration.enumerateObjects(ofType: BasicDataModel.className()) { oldObject, newObject in
//                        newObject!["buttonType"] = GV.ButtonType
//                    }
                default: migration.enumerateObjects(ofType: BasicDataModel.className())
                    { oldObject, newObject in
//                        newObject!["buttonType"] = GV.ButtonTypeSimple
                    }

                }
        },
            objectTypes: [GameDataModel.self, RoundDataModel.self, BasicDataModel.self, ScoreInfoForDifficulty.self, MyWords.self, FinishedGames.self, MyReportedWords.self, WordsFromCloud.self]
//            objectTypes: [WordListModel.self]
        )
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
//        loginToRealmSync()
        if reachability == nil {
            try! reachability = Reachability()
        }
        reachability!.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability!.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
//        let session = AVAudioSession.sharedInstance()
//        do {
//            try session.setCategory(AVAudioSession.Category.playback)
//        }
//        catch {
//            print("hier in setBackground")
//        }
//
//        realmSync = RealmService

        return true
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//        setIsOffline()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        GV.wtScene!.goBackground()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        GV.comeBackFromSleeping = true
        GV.mainViewController!.setDarkMode()
        

 
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        setIsOnline()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    private func loginToRealmSync() {
//        let userName = "magic-of-words-user"
//        let password = "@@@" + userName + "@@@"
//        GV.myUser = nil
//        let logInCredentials = SyncCredentials.usernamePassword(username: userName, password: password)
//        SyncUser.logIn(with: logInCredentials, server: GV.AUTH_URL, timeout: 5) { user, error in
//            if user == nil {
//                if SyncUser.current != nil {
//                    print("user offline")
//                    GV.myUser = SyncUser.current!
//                    self.setConnection()
//                }
//            } else {
//                print("OK user exists")
//                GV.myUser = user
//                self.setConnection()
//            }
//        }
//    }
//    
//    
//    func setIsOffline() {
//        if GV.myUser != nil {
//            try! realmSync!.safeWrite() {
//                if playerActivity?.count == 0 {
//                } else {
//                    if playerActivity![0].creationTime == nil {
//                        playerActivity![0].creationTime = Date()
//                    }
//                    if playerActivity![0].territory == nil {
//                        playerActivity![0].territory = GV.language.getPreferredLanguage()
//                        playerActivity![0].deviceType = UIDevice().modelName
//                    }
//                    playerActivity![0].countOnlines += 1
//                    playerActivity![0].isOnline = false
////                    playerActivity![0].onlineTime += Int(getLocalDate().timeIntervalSince(playerActivity![0].onlineSince!))
////                    playerActivity![0].onlineSince = nil
//                }
//            }
////            let subscriptions = realmSync!.subscriptions()
////            for subscription in subscriptions {
////                subscription.unsubscribe()
////            }
//        }
//    }
//    var playerActivitySubscription: SyncSubscription<PlayerActivity>?
//    var playerActivityToken: NotificationToken?
//    var playerNotificationToken: NotificationToken?
//
//    func setConnection() {
//        if GV.myUser == nil {
//            return
//        }
//        realmSync = RealmService
//        #if DEBUG
//        if GV.onIpad {
//            CopyRealm.shared.copyRealms()
//        }
//        #endif
////        let subscriptions = realmSync!.subscriptions()
////        for subscription in subscriptions {
////                subscription.unsubscribe()
////        }
// 
//        //        let myObjects = RealmService.objects(PlayerActivity.self)
//        //
//        //        let syncConfig: SyncConfiguration = SyncConfiguration(user: GV.myUser!, realmURL: GV.REALM_URL)
//        //        //        let syncConfig = SyncUser.current!.configuration(realmURL: GV.REALM_URL, user: GV.myUser!)
//        //        //        let config = SyncUser.current!.configuration(realmURL: GV.REALM_URL, fullSynchronization: false, enableSSLValidation: true, urlPrefix: nil)
//        //        let config = Realm.Configuration(syncConfiguration: syncConfig, objectTypes: [BestScoreSync.self, PlayerActivity.self])
//        if playerActivity == nil {
//            let name = GV.basicDataRecord.myName
////            let mySubspription = realmSync!.subscription(named: "PlayerActivity1:\(name)")
//            playerActivity = realmSync!.objects(PlayerActivity.self).filter("name = %@", name)
//            playerActivitySubscription = playerActivity!.subscribe(named: "PlayerActivity1:\(name)")
//            playerActivityToken = playerActivitySubscription!.observe(\.state) { /*[weak self]*/  state in
//                print("in AppDelegate setConnection -> state: \(state)")
//                if state == .complete {
//                    if playerActivity?.count == 0 {
//                        try! realmSync!.safeWrite() {
//                            let playerActivityItem = PlayerActivity()
//                            playerActivityItem.creationTime = Date()
//                            playerActivityItem.name = GV.basicDataRecord.myName
//                            playerActivityItem.nickName = GV.basicDataRecord.myNickname
//                            playerActivityItem.keyWord = GV.basicDataRecord.keyWord
//                            playerActivityItem.isOnline = true
//                            playerActivityItem.onlineSince = getLocalDate()
//                            playerActivityItem.onlineTime = 0
//                            playerActivityItem.territory = GV.language.getPreferredLanguage()
//                            playerActivityItem.country = Locale.current.regionCode
//                            playerActivityItem.deviceType = UIDevice().modelName
//                            playerActivityItem.version = actVersion
//                            realmSync!.add(playerActivityItem)
//                        }
//                    }  else {
//                        if GV.basicDataRecord.notSaved || GV.basicDataRecord.myNickname != playerActivity![0].nickName! || GV.basicDataRecord.keyWord != playerActivity![0].keyWord! {
//                            try! realm.safeWrite() {
//                                GV.basicDataRecord.myNickname = playerActivity![0].nickName!
//                                GV.basicDataRecord.keyWord = playerActivity![0].keyWord!
//                            }
//                        }
//                        if playerActivity![0].country != Locale.current.regionCode || playerActivity![0].territory != GV.language.getPreferredLanguage() {
//                            try! RealmService.safeWrite() {
//                                playerActivity![0].country = Locale.current.regionCode
//                                playerActivity![0].territory = GV.language.getPreferredLanguage()
//                            }
//                        }
//                        if playerActivity![0].version != actVersion {
//                            try! RealmService.safeWrite() {
//                                playerActivity![0].version = actVersion
//                            }
//                        }
//                    }
//                    self.playerNotificationToken = playerActivity!.observe {  (changes) in
//                        if playerActivity!.count > 0 {
//                            GV.expertUser = playerActivity!.first!.expertUser
//                        }
//                    }
//                    if GV.basicDataRecord.notSaved {
//                        try! realm.safeWrite() {
//                            GV.basicDataRecord.notSaved = false
//                        }
//                    }
//
//                } else {
//                }
//            }
//        }
//        setIsOnline()
//    }
//    
//    var tenMinutesTimer: Timer?
//    func setIsOnline() {
//        if GV.myUser != nil {
//            try! realmSync!.safeWrite() {
//                if playerActivity?.count == 0 {
//                } else {
//                    playerActivity![0].isOnline = true
//                    playerActivity![0].onlineSince = getLocalDate()
//                    playerActivity![0].lastTouched = getLocalDate()
//                    tenMinutesTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setLastTouched(timerX: )), userInfo: nil, repeats: false)
//                }
//            }
//            checkSyncedDB()
//        }
//    }
//    
//    @objc private func setLastTouched(timerX: Timer) {
//        tenMinutesTimer!.invalidate()
//        tenMinutesTimer = nil
//        try! realm.safeWrite() {
//            GV.basicDataRecord.onlineTime += 1
//            if GV.playing {
//                GV.basicDataRecord.playingTime += 1
//            }
//        }
//        if playerActivity?.count == 0 {
//        } else {
//            if GV.basicDataRecord.onlineTime % 60 == 0 {
//                try! RealmService.safeWrite() {
//                    playerActivity![0].lastTouched = getLocalDate()
//                    playerActivity![0].onlineTime = GV.basicDataRecord.onlineTime
//                    playerActivity![0].playingTime = GV.basicDataRecord.playingTime
//                }
//            }
//        }
//        tenMinutesTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setLastTouched(timerX: )), userInfo: nil, repeats: false)
//    }
//    
//    var bestScoreSync: Results<BestScoreSync>?
//    var notificationToken: NotificationToken?
//    var bestScoreSubscriptionToken: NotificationToken?
//    var forGameSubscriptionToken: NotificationToken?
//    var bestScoreSyncSubscription: SyncSubscription<BestScoreSync>?
//    var bestScoreForGame: Results<BestScoreForGame>?
//    var bestScoreForGameToken: NotificationToken?
//    var bestScoreForGameSubscription: SyncSubscription<BestScoreForGame>?
//    var syncedRecordsOK = false
//    var waitingForSynceRecords = false
//    var answer1Button: UIButton?
//    
//    
//    private func checkSyncedDB() {
//        let language = GV.language.getText(.tcAktLanguage)
//        let myName = GV.basicDataRecord.myName
//        let combinedPrimarySync = language + myName
//        let combinedPrimaryForGame = language
//// this block sets the local DB to NotSynced
////  ==================================
//        let myGameRecords = realm.objects(GameDataModel.self).filter("language = %@ and synced = true", language).sorted(byKeyPath: "gameNumber", ascending: true)
//        try! realm.safeWrite() {
//            for record in myGameRecords {
//                record.synced = false
//            }
//        }
//        //  ==================================
//        if realmSync != nil {
//            if !GV.debug {
//                let myGameRecords = realm.objects(GameDataModel.self).filter("language = %@ and synced = false", language).sorted(byKeyPath: "gameNumber", ascending: true)
//                if myGameRecords.count > 0 && bestScoreSync == nil {
//                    bestScoreSync = realmSync!.objects(BestScoreSync.self).filter("combinedPrimary ENDSWITH %@", combinedPrimarySync)
//                    bestScoreSyncSubscription = bestScoreSync!.subscribe(named: "AllMyScoreRecords:\(combinedPrimarySync)")
//                    bestScoreSubscriptionToken = bestScoreSyncSubscription!.observe(\.state) { [weak self]  state in
////                        print("in AppDelegate checkSyncedDB -> state: \(state)")
//                        if state == .complete {
//                            for record in myGameRecords {
//                                let actGameNumber = record.gameNumber + 1
//                                let syncedRecord = self!.bestScoreSync!.filter("gameNumber = %@", actGameNumber)
//                                if syncedRecord.count == 0 {
//                                    try! realmSync!.safeWrite() {
//                                        let bestScoreSyncRecord = BestScoreSync()
//                                        bestScoreSyncRecord.gameNumber = actGameNumber
//                                        bestScoreSyncRecord.language = language
//                                        bestScoreSyncRecord.playerName = myName
//                                        bestScoreSyncRecord.combinedPrimary = String(actGameNumber) + combinedPrimarySync
//                                        bestScoreSyncRecord.finished = record.gameStatus == GV.GameStatusFinished
//                                        bestScoreSyncRecord.score = record.score
//                                        bestScoreSyncRecord.owner = playerActivity?[0]
//                                        realmSync!.add(bestScoreSyncRecord)
//                                    }
//                                    try! realm.safeWrite() {
//                                        record.synced = true
//                                    }
//                                } else {
//                                    if syncedRecord.first!.score < record.score {
//                                        try! realmSync!.safeWrite() {
//                                            syncedRecord.first!.finished = record.gameStatus == GV.GameStatusFinished
//                                            syncedRecord.first!.score = record.score
//                                        }
//                                    }
//                                }
//                            }
//                        } else if state == .invalidated {
//                            self!.bestScoreSubscriptionToken = nil
////                            print ("state: \(state)")
//                        } else {
////                            print("state: \(state)")
//                        }
//                    }
//                    bestScoreForGame = realmSync!.objects(BestScoreForGame.self).filter("combinedPrimary ENDSWITH %@", combinedPrimaryForGame)
//                    bestScoreForGameSubscription = bestScoreForGame!.subscribe(named: "AllGameRecords:\(combinedPrimaryForGame)")
//                    forGameSubscriptionToken = bestScoreForGameSubscription!.observe(\.state) { [weak self]  state in
//                        //                print("in Subscription!")
//                        if state == .complete {
//                            for record in myGameRecords {
//                                try! realm.safeWrite() {
//                                    record.synced = true
//                                }
//                                let actGameNumber = record.gameNumber + 1
//                                let syncedRecord = self!.bestScoreForGame!.filter("gameNumber = %@", actGameNumber)
//                                if syncedRecord.count == 0 {
//                                    try! realmSync!.write {
//                                        let bestScoreSyncRecord = BestScoreForGame()
//                                        bestScoreSyncRecord.gameNumber = actGameNumber
//                                        bestScoreSyncRecord.language = language
//                                        bestScoreSyncRecord.combinedPrimary = String(actGameNumber) + combinedPrimaryForGame
//                                        bestScoreSyncRecord.bestScore = record.score
//                                        bestScoreSyncRecord.owner = playerActivity?[0]
//                                        realmSync!.add(bestScoreSyncRecord)
//                                    }
//                                } else {
//                                    if syncedRecord.first!.bestScore < record.score {
//                                        try! realmSync!.write {
//                                            syncedRecord.first!.bestScore = record.score
//                                        }
//                                    }
//                                }
//                                
//                            }
//                        } else {
////                            print("state: \(state)")
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    
}
//var RealmService = ReferenceRealm.shared.realm
//
//private class ReferenceRealm {
//    static let shared = ReferenceRealm()
//    
//    lazy var realm: Realm = {
//        let syncUserConfig = SyncUser.current?.configuration(realmURL: GV.REALM_URL, fullSynchronization: false, enableSSLValidation: true)
//        let realm = try! Realm(configuration: syncUserConfig!)
//        return realm
//    }()
//}

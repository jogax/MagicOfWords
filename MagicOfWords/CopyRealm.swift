//
//  CopyRealm.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 13/06/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//
// For copying of
//

import Foundation
import RealmSwift

class CopyRealm {
    static let shared = CopyRealm()
    private var oldPlayerActivity: Results<PlayerActivity>?
    private var oldPlayerNotificationToken: NotificationToken?
    private var oldPlayerActivitySubscription: SyncSubscription<PlayerActivity>?
    private var oldPlayerActivityToken: NotificationToken?
    private var oldBestScoreForGame: Results<BestScoreForGame>?
    private var oldBestScoreForGameNotificationToken: NotificationToken?
    private var oldBestScoreForGameSubscription: SyncSubscription<BestScoreForGame>?
    private var oldBestScoreForGameToken:  NotificationToken?
    private var oldBestScoreSync: Results<BestScoreSync>?
    private var oldBestScoreSyncNotificationToken: NotificationToken?
    private var oldBestScoreSyncSubscription: SyncSubscription<BestScoreSync>?
    private var oldBestScoreSyncToken:  NotificationToken?
    private var newPlayerActivity: Results<PlayerActivity>?
    private var newPlayerActivitySubscription: SyncSubscription<PlayerActivity>?
    private var newPlayerActivityToken: NotificationToken?
    private var newBestScoreForGame: Results<BestScoreForGame>?
    private var newBestScoreForGameSubscription: SyncSubscription<BestScoreForGame>?
    private var newBestScoreForGameToken:  NotificationToken?
    private var newBestScoreSync: Results<BestScoreSync>?
    private var newBestScoreSyncSubscription: SyncSubscription<BestScoreSync>?
    private var newBestScoreSyncToken:  NotificationToken?
   public func copyRealms() {
        var new_syncUserConfig = SyncUser.current?.configuration(realmURL: GV.NEW_REALM_URL, fullSynchronization: false, enableSSLValidation: true)
        new_syncUserConfig!.objectTypes = [PlayerActivity.self, BestScoreSync.self, BestScoreForGame.self]
        let new_realm = try! Realm(configuration: new_syncUserConfig!)
        var old_syncUserConfig = SyncUser.current?.configuration(realmURL: GV.REALM_URL, fullSynchronization: false, enableSSLValidation: true)
        old_syncUserConfig!.objectTypes = [PlayerActivity.self, BestScoreSync.self, BestScoreForGame.self]
        let old_realm = try! Realm(configuration: old_syncUserConfig!)
        
        oldPlayerActivity = old_realm.objects(PlayerActivity.self)
        oldPlayerActivitySubscription = oldPlayerActivity!.subscribe(named: "CopyPlayerActivity")
        oldPlayerActivityToken = oldPlayerActivitySubscription!.observe(\.state) {state in
            print("in copyRealms playerActivity state: \(state)")
            if state == .complete {
                print("OldPlayerActivity count records: \(self.oldPlayerActivity!.count)")
                self.newPlayerActivity = new_realm.objects(PlayerActivity.self)
                self.newPlayerActivitySubscription = self.newPlayerActivity!.subscribe(named: "NewPlayerActivity")
                self.newPlayerActivityToken = self.newPlayerActivitySubscription!.observe(\.state) {state in
                    if state == .complete {
                        print("NewPlayerActivity count records: \(self.newPlayerActivity!.count)")
                        for oldRecord in self.oldPlayerActivity! {
                            let newRecord = self.newPlayerActivity!.filter("name = %@", oldRecord.name)
                            if newRecord.count == 0 {
                                try! new_realm.safeWrite() {
                                    new_realm.add(oldRecord.copy())
                                }
                            } else {
                                var newRecord0 = newRecord[0]
                                if oldRecord.lastTouched != nil && newRecord0.lastTouched != nil && oldRecord.lastTouched! > newRecord0.lastTouched! {
                                    try! new_realm.safeWrite() {
                                        newRecord0 = oldRecord.copy()
                                    }
                                }
                            }
                        }
                        self.oldBestScoreForGame = old_realm.objects(BestScoreForGame.self)
                        self.oldBestScoreForGameSubscription = self.oldBestScoreForGame!.subscribe(named: "CopyBestScoreForGame")
                        self.oldBestScoreForGameToken = self.oldBestScoreForGameSubscription!.observe(\.state) {state in
                            if state == .complete {
                                print("OldBestScoreForGame count records: \(self.oldBestScoreForGame!.count)")
                                self.newBestScoreForGame = new_realm.objects(BestScoreForGame.self)
                                self.newBestScoreForGameSubscription = self.newBestScoreForGame!.subscribe(named: "NewBestScoreForGame")
                                self.newBestScoreForGameToken = self.newBestScoreForGameSubscription!.observe(\.state) {state in
                                    if state == .complete {
                                        for oldRecord in self.oldBestScoreForGame! {
                                            if oldRecord.owner != nil {
                                                let newOwner = self.newPlayerActivity!.filter("name = %@", oldRecord.owner!.name).first
                                                if newOwner != nil {
                                                    let newRecord = self.newBestScoreForGame!.filter("combinedPrimary = %@", oldRecord.combinedPrimary)
                                                    if newRecord.count == 0 {
                                                        try! new_realm.safeWrite() {
                                                            let new_Record: BestScoreForGame  = oldRecord.copy(newOwner: newOwner!)
                                                            new_realm.add(new_Record)
                                                        }
                                                    } else  {
                                                        var newRecord0 = newRecord[0]
                                                        if newRecord0.bestScore < oldRecord.bestScore {
                                                            try! new_realm.safeWrite() {
                                                                newRecord0 = oldRecord.copy(newOwner: newOwner!)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        print("BestScoreForGame count records: \(self.newBestScoreForGame!.count)")
                                        self.oldBestScoreForGameNotificationToken = self.oldBestScoreForGame!.observe {changes in
                                            switch changes {
                                            case .initial:
                                                break
                                            case .update:
                                                for oldRecord in self.oldBestScoreForGame! {
                                                    if oldRecord.owner != nil {
                                                        let newOwner = self.newPlayerActivity!.filter("name = %@", oldRecord.owner!.name).first
                                                        if newOwner != nil {
                                                            let newRecord = self.newBestScoreForGame!.filter("combinedPrimary = %@", oldRecord.combinedPrimary)
                                                            if newRecord.count == 0 {
                                                                try! new_realm.safeWrite() {
                                                                    let new_Record: BestScoreForGame  = oldRecord.copy(newOwner: newOwner!)
                                                                    new_realm.add(new_Record)
                                                                }
                                                            } else  {
                                                                var newRecord0 = newRecord[0]
                                                                if newRecord0.bestScore < oldRecord.bestScore {
                                                                    try! new_realm.safeWrite() {
                                                                        newRecord0 = oldRecord.copy(newOwner: newOwner!)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                            case .error(let error):
                                                // An error occurred while opening the Realm file on the background worker thread
                                                fatalError("\(error)")
                                            }
                                        }
                                        

                                    }
                                }
                                self.oldBestScoreSync = old_realm.objects(BestScoreSync.self)
                                self.oldBestScoreSyncSubscription = self.oldBestScoreSync!.subscribe(named: "CopyBestScoreSync")
                                self.oldBestScoreForGameToken = self.oldBestScoreSyncSubscription!.observe(\.state) {state in
                                    if state == .complete {
                                        print("oldBestScoreSync count records: \(self.oldBestScoreSync!.count)")
                                        self.newBestScoreSync = new_realm.objects(BestScoreSync.self)
                                        self.newBestScoreSyncSubscription = self.newBestScoreSync!.subscribe(named: "NewBestScoreSync")
                                        self.newBestScoreSyncToken = self.newBestScoreSyncSubscription!.observe(\.state) {state in
                                            if state == .complete {
                                                for oldRecord in self.oldBestScoreSync! {
                                                    if oldRecord.owner != nil {
                                                        let newOwner = self.newPlayerActivity!.filter("name = %@", oldRecord.owner!.name).first
                                                        if newOwner != nil {
                                                            let newRecords = self.newBestScoreSync!.filter("combinedPrimary = %@", oldRecord.combinedPrimary)
                                                            let newRecord: BestScoreSync = oldRecord.copy(newOwner: newOwner!)
                                                            if newRecords.count == 0 {
                                                                try! new_realm.safeWrite() {
                                                                    new_realm.add(newRecord)
                                                                }
                                                            } else {
                                                                var newRecord0 = newRecords[0]
                                                                if newRecord0.score < oldRecord.score {
                                                                    try! new_realm.safeWrite() {
                                                                        newRecord0 = newRecord
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                print("NewBestScoreSync count records: \(self.newBestScoreSync!.count)")
                                            }
                                        }
                                        self.oldBestScoreSyncNotificationToken = self.oldBestScoreSync!.observe {changes in
                                            switch changes {
                                            case .initial:
                                                break
                                            case .update:
                                                for oldRecord in self.oldBestScoreSync! {
                                                    if oldRecord.owner != nil {
                                                        let newOwner = self.newPlayerActivity!.filter("name = %@", oldRecord.owner!.name).first
                                                        if newOwner != nil {
                                                            let newRecords = self.newBestScoreSync!.filter("combinedPrimary = %@", oldRecord.combinedPrimary)
                                                            let newRecord: BestScoreSync = oldRecord.copy(newOwner: newOwner!)
                                                            if newRecords.count == 0 {
                                                                try! new_realm.safeWrite() {
                                                                    new_realm.add(newRecord)
                                                                }
                                                            } else {
                                                                var newRecord0 = newRecords[0]
                                                                if newRecord0.score < oldRecord.score {
                                                                    try! new_realm.safeWrite() {
                                                                        newRecord0 = newRecord
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            case .error(let error):
                                                // An error occurred while opening the Realm file on the background worker thread
                                                fatalError("\(error)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        self.oldPlayerNotificationToken = self.oldPlayerActivity!.observe {changes in
                            switch changes {
                            case .initial:
                                break
                            case .update:
                                break
                            case .error(let error):
                                // An error occurred while opening the Realm file on the background worker thread
                                fatalError("\(error)")
                            }
                        }

                    }
                }
            }
        }
    }
}

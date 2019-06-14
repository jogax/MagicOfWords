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
    private var oldPlayerActivitySubscription: SyncSubscription<PlayerActivity>?
    private var oldPlayerActivityToken: NotificationToken?
    private var oldBestScoreForGame: Results<BestScoreForGame>?
    private var oldBestScoreForGameSubscription: SyncSubscription<BestScoreForGame>?
    private var oldBestScoreForGameToken:  NotificationToken?
    private var oldBestScoreSync: Results<BestScoreSync>?
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
                                var newRecord1 = newRecord[0]
                                if oldRecord.lastTouched != nil && newRecord1.lastTouched != nil && oldRecord.lastTouched! > newRecord1.lastTouched! {
                                    try! new_realm.safeWrite() {
                                        newRecord1 = oldRecord.copy()
                                    }
                                }
                            }
                        }
                    }
                }
                print("PlayerActivity count records: \(new_realm.objects(PlayerActivity.self).count)")
                self.oldPlayerActivitySubscription!.unsubscribe()
                self.oldBestScoreForGame = old_realm.objects(BestScoreForGame.self)
                self.oldBestScoreForGameSubscription = self.oldBestScoreForGame!.subscribe(named: "CopyBestScoreForGame")
                self.oldBestScoreForGameToken = self.oldBestScoreForGameSubscription!.observe(\.state) {state in
                    if state == .complete {
                        print("BestScoreForGame count records: \(self.oldBestScoreForGame!.count)")
                        for record in self.oldBestScoreForGame! {
                            if record.owner != nil {
                                let newRecord = new_realm.objects(BestScoreForGame.self).filter("combinedPrimary = %@", record.combinedPrimary)
                                if newRecord.count == 0 {
                                    try! new_realm.safeWrite() {
                                        let newOwner = new_realm.objects(PlayerActivity.self).filter("name = %@", record.owner!.name).first
                                        if newOwner != nil {
                                            let new_Record: BestScoreForGame  = record.copy(newOwner: newOwner!)
                                            new_realm.add(new_Record)
                                        }
                                    }
                                }
                            }
                        }
                        print("BestScoreForGame count records: \(new_realm.objects(BestScoreForGame.self).count)")
                        self.oldBestScoreForGameSubscription!.unsubscribe()
                        self.oldBestScoreSync = old_realm.objects(BestScoreSync.self)
                        self.oldBestScoreSyncSubscription = self.oldBestScoreSync!.subscribe(named: "CopyBestScoreSync")
                        self.oldBestScoreForGameToken = self.oldBestScoreSyncSubscription!.observe(\.state) {state in
                            if state == .complete {
                                print("BestScoreSync count records: \(self.oldBestScoreSync!.count)")
                                for record in self.oldBestScoreSync! {
                                    if record.owner != nil {
                                        let newRecord = new_realm.objects(BestScoreSync.self).filter("combinedPrimary = %@", record.combinedPrimary)
                                        if newRecord.count == 0 {
                                            try! new_realm.safeWrite() {
                                                let newOwners = new_realm.objects(PlayerActivity.self).filter("name = %@", record.owner!.name)
                                                if newOwners.count == 1 {
                                                    let new_Record: BestScoreSync  = record.copy(newOwner: newOwners.first!)
                                                    new_realm.add(new_Record)
                                                }
                                            }
                                        }
                                    }
                                }
                                print("BestScoreSync count records: \(new_realm.objects(BestScoreSync.self).count)")
                                self.oldBestScoreSyncSubscription!.unsubscribe()
                            }
                        }
                    }
                }
                
            }
        }
    }
}

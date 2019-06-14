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
                print("PlayerActivity count records: \(self.oldPlayerActivity!.count)")
                for record in self.oldPlayerActivity! {
                    let newRecord = new_realm.objects(PlayerActivity.self).filter("name = %@", record.name)
                    if newRecord.count == 0 {
                        try! new_realm.safeWrite() {
                            new_realm.add(record.copy())
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

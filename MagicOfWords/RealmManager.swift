//
//  RealmManager.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 12/10/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

var RealmService = RealmManager.shared.realm

private class RealmManager {
    static let shared = RealmManager()
    
    lazy var realm: Realm = {
        var syncUserConfig = SyncUser.current?.configuration(realmURL: GV.REALM_URL, fullSynchronization: false, enableSSLValidation: true)
        syncUserConfig!.objectTypes = [PlayerActivity.self, BestScoreSync.self, BestScoreForGame.self, CommonString.self, Mandatory.self, ModifiedWordsModel.self, GameData.self, RoundData.self]
        let realm = try! Realm(configuration: syncUserConfig!)
        return realm
    }()
}

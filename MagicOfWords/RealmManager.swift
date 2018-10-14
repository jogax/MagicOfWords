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
        let syncUserConfig = SyncUser.current?.configuration(realmURL: GV.REALM_URL, fullSynchronization: false, enableSSLValidation: true)
        let realm = try! Realm(configuration: syncUserConfig!)
        return realm
    }()
}

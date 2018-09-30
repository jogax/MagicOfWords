//
//  PlayerActivity.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 13/09/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class PlayerActivity: Object {
    
    // Specify properties to ignore (Realm won't persist these)
    @objc dynamic var name: String = UUID().uuidString
    @objc dynamic var nickName: String?
    @objc dynamic var isOnline: Bool = false
    @objc dynamic var onlineSince: Date?
    @objc dynamic var onlineTime: Int = 0
 

    override static func primaryKey() -> String? {
        return "name"
    }

    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}

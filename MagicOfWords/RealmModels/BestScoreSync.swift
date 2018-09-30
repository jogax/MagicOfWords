//
//  BestScoreSync.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 13/09/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class BestScoreSync: Object {
    
// Specify properties to ignore (Realm won't persist these)
    @objc dynamic var combinedPrimary: String = ""
    @objc dynamic var gameNumber: String = ""
    @objc dynamic var language: String = ""
    @objc dynamic var playerName: String = ""
    @objc dynamic var score: Int = 0
    @objc dynamic var finished: Bool = false
    @objc dynamic var usedTime: Int = 0
    @objc dynamic var owner: PlayerActivity? // to-one relationships must be optional

    override static func primaryKey() -> String? {
        return "combinedPrimary"
    }

//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}

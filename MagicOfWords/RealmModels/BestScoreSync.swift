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
    @objc dynamic var gameNumber: Int = 0
    @objc dynamic var language: String = ""
    @objc dynamic var playerName: String = ""
    @objc dynamic var score: Int = 0

    override static func primaryKey() -> String? {
        return "gameNumber"
    }

//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}

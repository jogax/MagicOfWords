//
//  BestScoreForGame.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 05/10/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

// 1 record per gamenumber
class BestScoreForGame: Object {
    
    // Specify properties to ignore (Realm won't persist these)
    @objc dynamic var combinedPrimary: String = ""
    @objc dynamic var gameNumber: Int = 0
    @objc dynamic var language: String = ""
    @objc dynamic var difficulty: String = ""
//    @objc dynamic var bestPlayerName: String = ""
    @objc dynamic var bestScore: Int = 0
    @objc dynamic var timeStamp: Date = Date()
    @objc dynamic var owner: PlayerActivity? // to-one relationships must be optional

    override static func primaryKey() -> String? {
        return "combinedPrimary"
    }
    
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}

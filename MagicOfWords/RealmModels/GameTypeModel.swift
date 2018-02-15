//
//  OpenedGamesModel.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 13/02/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class GameTypeModel: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
    @objc dynamic var gameNumber = 0
    @objc dynamic var gameType = 0
    override  class func primaryKey() -> String {
        return "gameType"
    }
}

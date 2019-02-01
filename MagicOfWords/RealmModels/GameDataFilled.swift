//
//  GameDataFilled.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 01/02/2019.
//Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class GameDataFilled: Object {
        @objc dynamic var combinedKey = ""
        @objc dynamic var language = ""
        @objc dynamic var gameNumber = 0
        @objc dynamic var mandatoryWords = ""
        @objc dynamic var pieces = ""
        override  class func primaryKey() -> String {
            return "combinedKey"
        }
        
        
}


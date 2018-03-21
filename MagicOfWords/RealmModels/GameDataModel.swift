//
//  GameDataModel.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 07/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class GameDataModel: Object {
    
    @objc dynamic var gameType = 0
    @objc dynamic var gameNumber = 0
    @objc dynamic var words = ""
    @objc dynamic var pieces = ""
    @objc dynamic var indexes = ""
    override  class func primaryKey() -> String {
        return "words"
    }
    
    
}

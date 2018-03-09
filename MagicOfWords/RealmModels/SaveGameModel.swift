//
//  SaveGameModel.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 08/03/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class SaveGameModel: Object {
    @objc dynamic var gameType = 0
    @objc dynamic var gameNumber = 0
    @objc dynamic var gameArray = "" // the letters in gameArray or " "
    @objc dynamic var tiles = "" // all generated tiles for a game in form "form, rotateIndex, letters from 0 to max"
    
    override  class func primaryKey() -> String {
        return "gameNumber"
    }
}



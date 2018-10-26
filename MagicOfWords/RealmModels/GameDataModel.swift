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
    @objc dynamic var combinedKey = ""
    @objc dynamic var language = ""
    @objc dynamic var gameNumber = 0
    @objc dynamic var nowPlaying = false
    @objc dynamic var gameStatus = 0 // 0: new, 1: playing, 2: finished
    @objc dynamic var mandatoryWords = ""
    @objc dynamic var ownWords = ""
    @objc dynamic var pieces = ""
    @objc dynamic var score = 0  // Score
    @objc dynamic var time = ""
    let rounds = List<RoundDataModel>()
    override  class func primaryKey() -> String {
        return "combinedKey"
    }
    
    
}

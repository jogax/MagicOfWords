//
//  GameDataModel.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 21/03/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class GameData: Object {
    @objc dynamic var combinedKey = "" // language + gameNumber + owner.name
    @objc dynamic var language = ""
    @objc dynamic var gameNumber = 0
    @objc dynamic var nowPlaying = false
    @objc dynamic var gameStatus = 0 // 0: new, 1: playing, 2: finished, 3: continued
    @objc dynamic var mandatoryWords = ""
    @objc dynamic var ownWords = ""
    @objc dynamic var pieces = ""
    @objc dynamic var words = ""
    @objc dynamic var score = 0  // Score
    @objc dynamic var time = ""
    @objc dynamic var synced = false
    @objc dynamic var owner: PlayerActivity?
    let rounds = List<RoundData>()
    override  class func primaryKey() -> String {
        return "combinedKey"
    }
    
    
}
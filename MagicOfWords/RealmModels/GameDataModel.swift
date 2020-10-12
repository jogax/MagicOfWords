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
    @objc dynamic var sizeOfGrid = 10
    @objc dynamic var gameType = -1
    @objc dynamic var nowPlaying = false
    @objc dynamic var prefillPercentage = 0
    @objc dynamic var countRounds = 1
    @objc dynamic var gameStatus = 0 // 0: new, 1: playing, 2: finished, 3: continued
    @objc dynamic var mandatoryWords = ""
    @objc dynamic var ownWords = ""
    @objc dynamic var pieces = ""
    @objc dynamic var words = ""
    @objc dynamic var score = 0  // Score
    @objc dynamic var hintTable = ""
    @objc dynamic var time = ""
    @objc dynamic var synced = false
    @objc dynamic var countOfWordsMaxValue = 1000
    @objc dynamic var countOfLettersMaxValue = 250
    @objc dynamic var created: Date = Date()
    @objc dynamic var modified: Date = Date2000_1_1
    @objc dynamic var recordVersion = 0
//    @objc dynamic var randomCounts = 0
    let rounds = List<RoundDataModel>()
    override  class func primaryKey() -> String {
        return "combinedKey"
    }
    static public var Date2000_1_1 = Date(year: 2000, month: 1, day: 1)

    
    public func copy(newCombinedKey: String)->GameDataModel {
        let newRecord = GameDataModel()
        
        newRecord.combinedKey = newCombinedKey
        newRecord.language = self.language
        newRecord.gameNumber = self.gameNumber
        newRecord.sizeOfGrid = self.sizeOfGrid
        newRecord.nowPlaying = self.nowPlaying
        newRecord.gameStatus = self.gameStatus
        newRecord.mandatoryWords = self.mandatoryWords
        newRecord.ownWords = self.ownWords
        newRecord.pieces = self.pieces
        newRecord.words = self.words
        newRecord.score = self.score
        newRecord.time = self.time
        newRecord.synced = self.synced
        for round in self.rounds {
            newRecord.rounds.append(round)
        }
        return newRecord
    }
    
    
}
